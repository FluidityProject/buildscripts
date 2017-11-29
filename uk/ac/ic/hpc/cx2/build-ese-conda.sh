#!/bin/sh

# Prefix for build

PREFIX=/home/software-ese/software-cx2

# We want everything python to use conda
unset PYTHONPATH

# Get Conda
CONDA_SERVER=https://repo.continuum.io/
CONDA_SERVERDIR=miniconda/
CONDA_INSTALLER=Miniconda2-latest-Linux-x86_64.sh

curl -O ${CONDA_SERVER}${CONDA_SERVERDIR}${CONDA_INSTALLER}

# Version is a bit arbitrary here; use date string
CONDA_VERSION=`date +%s`
CONDA_INSTALLDIR=${PREFIX}/interpreters/conda/${CONDA_VERSION}

# Install conda without prompting
bash ./${CONDA_INSTALLER} -b -f -p ${CONDA_INSTALLDIR}

# Point to the conda binary
export PATH="${CONDA_INSTALLDIR}/bin:$PATH"
export CONDA_VTK_VERSION="5.10"

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
   ${CONDA_INSTALLDIR}/build-ese-conda-${CONDA_VERSION}.sh

# Install other packages needed by Fluidity
conda install -y numpy scipy vtk=${CONDA_VTK_VERSION} sympy matplotlib
conda install -c scitools -y udunits 

# Deal with the messy TCL breaking modules

mkdir ${CONDA_INSTALLDIR}/lib/tcl
mv ${CONDA_INSTALLDIR}/lib/libtcl* ${CONDA_INSTALLDIR}/lib/tcl/

# Write out a modulefile

mkdir -p  ${PREFIX}/modules/ese-conda

cat > ${PREFIX}/modules/ese-conda/${CONDA_VERSION} << EOF
#%Module

proc ModulesHelp { } {
    puts stderr "This module sets the path and environment variables for anaconda ${CONDA_VERSION}"
    puts stderr ""
}
module-whatis "Anaconda ${CONDA_VERSION}"

set basedir ${CONDA_INSTALLDIR}

prepend-path PATH \${basedir}/bin
prepend-path LD_LIBRARY_PATH \${basedir}/lib

setenv CONDA_HOME \${basedir}

append-path --delim " " CPPFLAGS -I\${basedir}/include
append-path --delim " " CFLAGS -L\${basedir}/lib
append-path --delim " " FFLAGS -L\${basedir}/lib
append-path --delim " " CXXFLAGS -L\${basedir}/lib
append-path --delim " " LDFLAGS -L\${basedir}/lib

EOF

