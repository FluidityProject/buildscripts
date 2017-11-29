#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese/software-cx1
PETSC_VERSION=3.7.5
PETSC_TARBALL=petsc-lite-${PETSC_VERSION}.tar.gz
PETSC_SERVER="http://ftp.mcs.anl.gov/"
PETSC_SERVERDIR="pub/petsc/release-snapshots/"
PETSC_BUILDROOT=${PREFIX}/builds/petsc/${PETSC_VERSION}-${ESE_COMPILER}
PETSC_SOURCEDIR=${PETSC_BUILDROOT}/petsc-${PETSC_VERSION}
PETSC_INSTALLDIR=${PREFIX}/libraries/ese-petsc/${PETSC_VERSION}-${ESE_COMPILER}

# Archive any existing source tree
if [ -d ${PETSC_BUILDROOT} ] ; then
  mv ${PETSC_BUILDROOT} ${PETSC_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${PETSC_SOURCEDIR}

# Fetch and unpack a new source
pushd ${PETSC_BUILDROOT}
curl -s ${PETSC_SERVER}${PETSC_SERVERDIR}${PETSC_TARBALL} | tar -zxf -

# PETSc tarball is missing bin/maint - pull from master
PETSC_MASTERSVNURL="https://github.com/petsc/petsc.git/trunk"

svn export ${PETSC_MASTERSVNURL}/bin/maint $PETSC_SOURCEDIR/bin/maint

# PETSc builds in its own sourcetree
pushd ${PETSC_SOURCEDIR}

# Fix needed in generatefortranstubs

sed -i 's/os.mkdir/os.makedirs/g' bin/maint/generatefortranstubs.py

# Set up the PETSc build environment
export PETSC_ARCH=linux-gnu-c-opt
export PETSC_DIR=${PWD}

# Configure and build PETSc
./configure \
 --with-shared-libraries \
 --with-debugging=0 \
 --PETSC_ARCH=${PETSC_ARCH} \
 --download-hypre=1 \
 --download-metis=1 \
 --download-ml=1 \
 --download-mumps=1 \
 --download-parmetis=1 \
 --download-sowing=1 \
 --download-triangle=1 \
 --download-ptscotch=1 \
 --download-suitesparse=1 \
 --download-ctetgen=1 \
 --download-chaco=1 \
 --download-scalapack=1 \
 --download-blacs=1 \
 --download-hdf5=1 \
 --download-fblaslapack=1 \
 --known-mpi-shared-libraries=1 \
 --prefix=${PETSC_INSTALLDIR} \
 --with-fortran-interfaces=1 \
 --with-mpi-dir=${I_MPI_ROOT} \
 --with-valgrind-dir=${VALGRIND_HOME}

make PETSC_DIR=${PWD} PETSC_ARCH=${PETSC_ARCH} all
make PETSC_DIR=${PWD} PETSC_ARCH=${PETSC_ARCH} install

# Revert to our previous location
popd
popd

# link blas and lapack libraries to expected names
ln -s ${PETSC_INSTALLDIR}/lib/libfblas.a ${PETSC_INSTALLDIR}/lib/libblas.a 
ln -s ${PETSC_INSTALLDIR}/lib/libflapack.a ${PETSC_INSTALLDIR}/lib/liblapack.a 


# Now set up the zoltan build
ZOLTAN_VERSION=v3.83
ZOLTAN_TARBALL=zoltan_distrib_${ZOLTAN_VERSION}.tar.gz
ZOLTAN_SERVER="http://www.cs.sandia.gov/"
ZOLTAN_SERVERDIR="~kddevin/Zoltan_Distributions/"
ZOLTAN_BUILDROOT=${PREFIX}/builds/zoltan/${ZOLTAN_VERSION}
ZOLTAN_SOURCEDIR=${ZOLTAN_BUILDROOT}/Zoltan_${ZOLTAN_VERSION}
ZOLTAN_BUILDDIR=${ZOLTAN_BUILDROOT}/zoltan-${ZOLTAN_VERSION}-build

# Archive any existing source tree
if [ -d ${ZOLTAN_BUILDROOT} ] ; then
  mv ${ZOLTAN_BUILDROOT} ${ZOLTAN_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${ZOLTAN_BUILDDIR}
mkdir -p ${PETSC_INSTALLDIR}

# Fetch and unpack a new source
pushd ${ZOLTAN_BUILDROOT}
curl -s ${ZOLTAN_SERVER}${ZOLTAN_SERVERDIR}${ZOLTAN_TARBALL} | tar -zxf -

# Change into the build directory
pushd ${ZOLTAN_BUILDDIR}

# Set up the build environment
ZOLTAN_LIBDIR=${PETSC_INSTALLDIR}/lib
ZOLTAN_INCDIR=${PETSC_INSTALLDIR}/include

# With some Zoltan-build-local environment, configure Zoltan
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ZOLTAN_LIBDIR} \
LDFLAGS="-L${PETSC_INSTALLDIR}/lib" CPPFLAGS="-I${PETSC_INSTALLDIR}/include" \
  ${ZOLTAN_SOURCEDIR}/configure \
  --prefix=${PETSC_INSTALLDIR} \
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
   ${PETSC_INSTALLDIR}/build-ese-petsc-${PETSC_VERSION}-${ESE_COMPILER}.sh

# Write module 

mkdir -p ${PREFIX}/modules/ese-petsc

cat > ${PREFIX}/modules/ese-petsc/${PETSC_VERSION}-${ESE_COMPILER} << EOF
#%Module

proc ModulesHelp { } {
    puts stderr "This module sets the path and environment variables for petsc-${PETSC_VERSION}-${ESE_COMPILER}"
    puts stderr "     see http://www.mcs.anl.gov/petsc/ for more information      "
    puts stderr ""
}
module-whatis "PETSc - Portable, Extensible Toolkit for Scientific Computation"

set basedir ${PETSC_INSTALLDIR}

setenv PETSC_VERSION ${PETSC_VERSION}-${ESE_COMPILER}
setenv PETSC_DIR \${basedir}
setenv PETSC_HOME \${basedir}
setenv PETSC_ARCH ${PETSC_ARCH}
setenv UMFPACK_DIR \${basedir}

append-path PATH \${basedir}/bin
append-path LD_LIBRARY_PATH \${basedir}/lib
append-path INCLUDE \${basedir}/include
EOF
