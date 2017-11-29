#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese/software-cx2
GMP_VERSION=6.1.2
GMP_SERVER=https://gmplib.org/
GMP_SERVERDIR=download/gmp/
GMP_TARBALL=gmp-${GMP_VERSION}.tar.xz
GMP_BUILDROOT=${PREFIX}/builds/gmp/${GMP_VERSION}
GMP_SOURCEDIR=${GMP_BUILDROOT}/gmp-${GMP_VERSION}
GMP_BUILDDIR=${GMP_BUILDROOT}/gmp-${GMP_VERSION}-build
GMP_INSTALLDIR=${PREFIX}/compilers/ese-gmp/${GMP_VERSION}

# Archive any existing source tree
if [ -d ${GMP_BUILDROOT} ] ; then
  mv ${GMP_BUILDROOT} ${GMP_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${GMP_BUILDDIR}
mkdir -p ${GMP_INSTALLDIR}

# Fetch and unpack a new source
pushd ${GMP_BUILDROOT}
curl -s ${GMP_SERVER}${GMP_SERVERDIR}${GMP_TARBALL} | tar -Jxf -

# Change into the build directory
pushd ${GMP_BUILDDIR}

# Configure
${GMP_SOURCEDIR}/configure --prefix=${GMP_INSTALLDIR} --enable-cxx

# Build and install
make && make install

popd
popd

# Make a copy of this script for future reference

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
SCRIPT_NAME="$(basename $SOURCE)"

cp ${SCRIPT_DIR}/${SCRIPT_NAME} \
   ${GMP_INSTALLDIR}/build-ese-gmp-${GMP_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules/ese-gmp
cat > ${PREFIX}/modules/ese-gmp/${GMP_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${GMP_INSTALLDIR}

module load mpi

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

setenv GMP_HOME ${GMP_INSTALLDIR}

EOF
