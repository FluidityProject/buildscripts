#!/bin/sh
#
# Fluidity buildenv script written for CX2 with local PETSc, Zoltan, NetCDF, and conda

# Prefix for build

PREFIX=/home/fluidity/cx2-****INSERT_DATE_STRING_HERE****

# We want everything python to use conda
unset PYTHONPATH

# Get Conda
CONDA_SERVER=https://repo.continuum.io/
CONDA_SERVERDIR=miniconda/
CONDA_INSTALLER=Miniconda2-latest-Linux-x86_64.sh

curl -O ${CONDA_SERVER}${CONDA_SERVERDIR}${CONDA_INSTALLER}

# Install conda without prompting
bash ./${CONDA_INSTALLER} -b -f -p ${PREFIX}

# Point to the conda binary
export PATH="${PREFIX}/bin:$PATH"

export CONDA_VTK_VERSION="5.10"

# Install other packages needed by Fluidity
conda install -y numpy scipy vtk=${CONDA_VTK_VERSION} sympy matplotlib
conda install -c scitools -y udunits

# Get the PETSc tarball
PETSC_VERSION=3.7.4
PETSC_TARBALL=petsc-lite-${PETSC_VERSION}.tar.gz
PETSC_SERVER="http://ftp.mcs.anl.gov/"
PETSC_SERVERDIR="pub/petsc/release-snapshots/"

curl -s ${PETSC_SERVER}${PETSC_SERVERDIR}${PETSC_TARBALL} | tar -zxf -

# PETSc tarball is missing bin/maint - pull from master
PETSC_MASTERSVNURL="https://github.com/petsc/petsc.git/trunk"
PETSC_SOURCEDIR=petsc-${PETSC_VERSION}

svn export ${PETSC_MASTERSVNURL}/bin/maint $PETSC_SOURCEDIR/bin/maint

# Change into the PETSc sourcedir
pushd ${PETSC_SOURCEDIR}

export PETSC_DIR=${PWD}

# Set up the PETSc build environment
VALGRIND_DIR=/apps/valgrind/3.11.0
MPI_DIR=/apps/mpt/mpt-2.14
PETSC_ARCH=linux-gnu-opt

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
 --prefix=${PREFIX} \
 --with-fortran-interfaces=1 \
 --with-mpi-dir=${MPI_DIR} \
 --with-valgrind-dir=${VALGRIND_DIR}

make PETSC_DIR=$PWD PETSC_ARCH=${PETSC_ARCH} all
make PETSC_DIR=$PWD PETSC_ARCH=${PETSC_ARCH} install

# Revert to our previous location
popd

# link blas and lapack libraries to expected names
ln -s ${PREFIX}/lib/libfblas.a ${PREFIX}/lib/libblas.a
ln -s ${PREFIX}/lib/libflapack.a ${PREFIX}/lib/liblapack.a

# NetCDF-C build

# Obtain source
NETCDF_VERSION="4.4.1"
NETCDF_TARBALL="netcdf-${NETCDF_VERSION}.tar.gz"
NETCDF_SERVER="ftp://ftp.unidata.ucar.edu/"
NETCDF_SERVERDIR="pub/netcdf/"

curl -s ${NETCDF_SERVER}${NETCDF_SERVERDIR}${NETCDF_TARBALL} | tar -zxf -

NETCDF_SOURCEDIR=netcdf-${NETCDF_VERSION}

# Change into the source directory
pushd ${NETCDF_SOURCEDIR}

# Configure and build
CC=mpicc ./configure --prefix=${PREFIX}

make install

# Return to our previous directory
popd

# NetCDF-Fortran build

# Obtain source
NETCDFF_VERSION="4.4.4"
NETCDFF_TARBALL="netcdf-fortran-${NETCDFF_VERSION}.tar.gz"

curl -s ${NETCDF_SERVER}${NETCDF_SERVERDIR}${NETCDFF_TARBALL} | tar -zxf -

NETCDFF_SOURCEDIR=netcdf-fortran-${NETCDFF_VERSION}

# Change into the source directory
pushd ${NETCDFF_SOURCEDIR}

# Configure and build
LDFLAGS="-L${PREFIX}/lib" CPPFLAGS="-I${PREFIX}/include" \
   LIBS="-L${PREFIX}/lib" \
   ./configure --prefix=${PREFIX}

make install

# Return to our previous directory
popd

# Obtain source for Zoltan
ZOLTAN_VERSION=v3.83
ZOLTAN_TARBALL=zoltan_distrib_${ZOLTAN_VERSION}.tar.gz
ZOLTAN_SERVER="http://www.cs.sandia.gov/"
ZOLTAN_SERVERDIR="~kddevin/Zoltan_Distributions/"

curl -s ${ZOLTAN_SERVER}${ZOLTAN_SERVERDIR}${ZOLTAN_TARBALL} | tar -zxf -

# Create the Zoltan build directory and change into it
ZOLTAN_SOURCEDIR=${PWD}/Zoltan_${ZOLTAN_VERSION}
ZOLTAN_BUILDDIR=${PWD}/zoltan-build

mkdir ${ZOLTAN_BUILDDIR}

pushd ${ZOLTAN_BUILDDIR}

# Set up the Zoltan build environment
ZOLTAN_LIBDIR=${PREFIX}/lib
ZOLTAN_INCDIR=${PREFIX}/include

# With some Zoltan-build-local environment, configure Zoltan
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ZOLTAN_LIBDIR} \
  ${ZOLTAN_SOURCEDIR}/configure \
  --prefix=${PREFIX} \
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

# Return to our previous location
popd
