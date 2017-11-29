#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese/software-cx1
GCC_VERSION=6.3.0
GCC_SERVER=ftp://ftp.mirrorservice.org/
GCC_SERVERDIR=sites/sourceware.org/pub/gcc/releases/gcc-${GCC_VERSION}/
GCC_TARBALL=gcc-${GCC_VERSION}.tar.gz
GCC_BUILDROOT=${PREFIX}/builds/gcc/${GCC_VERSION}
GCC_SOURCEDIR=${GCC_BUILDROOT}/gcc-${GCC_VERSION}
GCC_BUILDDIR=${GCC_BUILDROOT}/gcc-${GCC_VERSION}-build
GCC_INSTALLDIR=${PREFIX}/compilers/ese-gcc/${GCC_VERSION}

# Archive any existing source tree
if [ -d ${GCC_BUILDROOT} ] ; then
  mv ${GCC_BUILDROOT} ${GCC_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${GCC_BUILDDIR}
#mkdir -p ${GCC_INSTALLDIR}

# Fetch and unpack a new source
pushd ${GCC_BUILDROOT}
curl -s ${GCC_SERVER}${GCC_SERVERDIR}${GCC_TARBALL} | tar -zxf -

# Change into the build directory
pushd ${GCC_BUILDDIR}

# Configure
${GCC_SOURCEDIR}/configure --prefix=${GCC_INSTALLDIR} \
     --enable-languages=c,c++,fortran,go --disable-multilib

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
   ${GCC_INSTALLDIR}/build-ese-gcc-${GCC_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules-cx1/ese-gcc

cat > ${PREFIX}/modules-cx1/ese-gcc/${GCC_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${GCC_INSTALLDIR}

module load mpi

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

setenv I_MPI_F90   gfortran
setenv I_MPI_F77   gfortran
setenv I_MPI_FC    gfortran
setenv I_MPI_CC    gcc
setenv I_MPI_CXX   g++

EOF
