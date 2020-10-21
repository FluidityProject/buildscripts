#!/bin/bash

# Set up initial environment
PREFIX=${SETLOCALPREFIX}
OPENMPI_VERSION_MAJOR=4
OPENMPI_VERSION_MINOR=0
OPENMPI_VERSION_SUBMINOR=3
OPENMPI_VERSION=${OPENMPI_VERSION_MAJOR}.${OPENMPI_VERSION_MINOR}.${OPENMPI_VERSION_SUBMINOR}
OPENMPI_SERVER=https://download.open-mpi.org/
OPENMPI_SERVERDIR=release/open-mpi/v${OPENMPI_VERSION_MAJOR}.${OPENMPI_VERSION_MINOR}/
OPENMPI_TARBALL=openmpi-${OPENMPI_VERSION}.tar.gz
OPENMPI_BUILDROOT=${PREFIX}/builds/openmpi/${OPENMPI_VERSION}-${ESE_COMPILER}
OPENMPI_SOURCEDIR=${OPENMPI_BUILDROOT}/openmpi-${OPENMPI_VERSION}
OPENMPI_BUILDDIR=${OPENMPI_BUILDROOT}/openmpi-${OPENMPI_VERSION}-build
OPENMPI_INSTALLDIR=${PREFIX}/compilers/openmpi/${OPENMPI_VERSION}-${ESE_COMPILER}

# Archive any existing source tree
if [ -d ${OPENMPI_BUILDROOT} ] ; then
  mv ${OPENMPI_BUILDROOT} ${OPENMPI_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${OPENMPI_BUILDDIR}
mkdir -p ${OPENMPI_INSTALLDIR}

# Fetch and unpack a new source
pushd ${OPENMPI_BUILDROOT}
curl -lks ${OPENMPI_SERVER}${OPENMPI_SERVERDIR}${OPENMPI_TARBALL} | tar -zxf -

# Change into the build directory
pushd ${OPENMPI_BUILDDIR}

# Configure
${OPENMPI_SOURCEDIR}/configure --prefix=${OPENMPI_INSTALLDIR} \
     --enable-mpi-thread-multiple \
     --disable-silent-rules --enable-mpi-cxx \
     CC=gcc CXX=g++ F77=gfortran FC=gfortran

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
   ${OPENMPI_INSTALLDIR}/build-openmpi-${OPENMPI_VERSION}-${ESE_COMPILER}.sh

# Write module 

mkdir -p ${PREFIX}/modules/openmpi

cat > ${PREFIX}/modules/openmpi/${OPENMPI_VERSION}-${ESE_COMPILER} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${OPENMPI_INSTALLDIR}

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
