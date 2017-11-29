#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese
ZOLTAN_VERSION=v3.83
ZOLTAN_TARBALL=zoltan_distrib_${ZOLTAN_VERSION}.tar.gz
ZOLTAN_SERVER="http://www.cs.sandia.gov/"
ZOLTAN_SERVERDIR="~kddevin/Zoltan_Distributions/"
ZOLTAN_BUILDROOT=${PREFIX}/builds/zoltan/${ZOLTAN_VERSION}
ZOLTAN_SOURCEDIR=${ZOLTAN_BUILDROOT}/Zoltan_${ZOLTAN_VERSION}
ZOLTAN_BUILDDIR=${ZOLTAN_BUILDROOT}/zoltan-${ZOLTAN_VERSION}-build
ZOLTAN_INSTALLDIR=${PETSC_DIR}


# Archive any existing source tree
if [ -d ${ZOLTAN_BUILDROOT} ] ; then
  mv ${ZOLTAN_BUILDROOT} ${ZOLTAN_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${ZOLTAN_BUILDDIR}
mkdir -p ${ZOLTAN_INSTALLDIR}

# Fetch and unpack a new source
pushd ${ZOLTAN_BUILDROOT}
curl -s ${ZOLTAN_SERVER}${ZOLTAN_SERVERDIR}${ZOLTAN_TARBALL} | tar -zxf -

# Change into the build directory
pushd ${ZOLTAN_BUILDDIR}

# Set up the build environment
ZOLTAN_LIBDIR=${PETSC_DIR}/lib
ZOLTAN_INCDIR=${PETSC_DIR}/include

# With some Zoltan-build-local environment, configure Zoltan
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ZOLTAN_LIBDIR} \
LDFLAGS="-L${ZOLTAN_INSTALLDIR}/lib" CPPFLAGS="-I${ZOLTAN_INSTALLDIR}/include" \
  ${ZOLTAN_SOURCEDIR}/configure \
  --prefix=${ZOLTAN_INSTALLDIR} \
  --libdir=${ZOLTAN_LIBDIR} \
  --enable-mpi \
  --with-mpi-compilers \
  --with-gnumake \
  --enable-zoltan \
  --enable-f90interface \
  --enable-zoltan-cppdriver \
  --disable-examples \
  --with-parmetis \
  --with-parmetis-libdir=${ZOLTAN_LIBDIR} \
  --with-parmetis-incdir=${ZOLTAN_INCDIR} \
  --with-scotch \
  --with-scotch-libdir=${ZOLTAN_LIBDIR} \
  --with-scotch-incdir=${ZOLTAN_INCDIR}

# Build and install Zoltan
make install

# Pop back to our original location
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
   ${ZOLTAN_INSTALLDIR}/build-ese-zoltan-${ZOLTAN_VERSION}.sh

# No module as Zoltan is wrapped in to PETSc
