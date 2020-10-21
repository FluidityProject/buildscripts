#!/bin/sh

# Prefix for build

PREFIX=${SETLOCALPREFIX}

# We want everything python to use conda
unset PYTHONPATH

# Get Conda
CONDA_SERVER=https://repo.anaconda.com/
CONDA_SERVERDIR=miniconda/
CONDA_INSTALLER=Miniconda3-latest-Linux-x86_64.sh

curl -O ${CONDA_SERVER}${CONDA_SERVERDIR}${CONDA_INSTALLER}

# Version is a bit arbitrary here; use date string
CONDA_VERSION=`date +%s`
CONDA_INSTALLDIR=${PREFIX}/interpreters/conda3/${CONDA_VERSION}-h5pyTest

# Set TMPDIR as the default isn't writeable on some HPC systems
TMPDIR=${PREFIX}/tmp

# Install conda without prompting
bash ./${CONDA_INSTALLER} -p ${CONDA_INSTALLDIR}

# Point to the conda binary
export PATH="${CONDA_INSTALLDIR}/bin:$PATH"

# Make a copy of this script for future reference

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
SCRIPT_NAME="$(basename $SOURCE)"

echo ${SCRIPT_DIR}/${SCRIPT_NAME} \
   ${CONDA_INSTALLDIR}/build-conda3-${CONDA_VERSION}.sh

# Install mpi4py for the VTK build
conda install -c intel mpi4py

# Install other packages needed by Fluidity
conda install -y numpy scipy sympy matplotlib lxml conda-build conda-verify
pip install junit-xml

# Install udunits2
conda install -c conda-forge/label/gcc7 udunits2

# Deal with the messy TCL breaking modules; uncomment if this is an issue
#
#mkdir ${CONDA_INSTALLDIR}/lib/tcl
#mv ${CONDA_INSTALLDIR}/lib/libtcl* ${CONDA_INSTALLDIR}/lib/tcl/

pushd ${TMPDIR}
  git clone https://github.com/FluidityProject/ichpc-h5py-feedstock.git
  pushd ${TMPDIR}/ichpc-h5py-feedstock/recipe
    conda build .
  popd
popd

# Write out a modulefile

mkdir -p  ${PREFIX}/modules/conda3

echo ${PREFIX}/modules/conda3/${CONDA_VERSION}

cat > ${PREFIX}/modules/conda3/${CONDA_VERSION} << EOF
#%Module

proc ModulesHelp { } {
    puts stderr "This module sets the path and environment variables for anaconda ${CONDA_VERSION}"
    puts stderr ""
}
module-whatis "Anaconda ${CONDA_VERSION}"

set basedir ${CONDA_INSTALLDIR}

setenv PYTHONHOME \${basedir}

prepend-path PATH \${basedir}/bin

append-path --delim " " CPPFLAGS -I\${basedir}/include
append-path     LD_LIBRARY_PATH \${basedir}/lib
append-path --delim " " LDFLAGS -L\${basedir}/lib


EOF

find $PREFIX -type d -exec chmod 755 '{}' \;
find $PREFIX -perm 700 -exec chmod 755 '{}' \;
find $PREFIX -perm 600 -exec chmod 644 '{}' \;

