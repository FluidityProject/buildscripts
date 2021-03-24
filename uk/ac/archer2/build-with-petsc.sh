#!/usr/bin/env bash
# Initial buildscript for Archer2 - minimally tested, use at your own risk!
#
# Note that all supporting software bar VTK and PETSc+HYPRE are available from
# system modules. There are currently no plans to support VTK as a system
# module, hence we have to build it locally. At the next round of rebuilds
# PETSc+HYPRE is likely to become available - this appears to have been
# broken in the system build unintentionally.
# 
# Note that at runtime to use the Fluidity binary built by this module you will
# need to do at least the following environment setup:
# 
#   module restore -s PrgEnv-gnu
#   module swap gcc gcc/9.3.0
#   module load cray-python
#   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CRAY_PYTHON_PREFIX}/lib  

# Stop the build on error

set -e

# Where Fluidity will be built - edit this to your preferred location
export FLUIDITY_PREFIX=${HOME}/fluidity-with-local-petsc

# Use GNU compilers
module restore -s PrgEnv-gnu

# Set up compiler environment to use Archer2 wrappers
export CC=cc
export CXX=CC
export FC=ftn
export F77=ftn
export F90=ftn
export MPIFC=ftn
export MPICC=cc
export MPICXX=CC

# For now, use GCC9 which is tested; 10 is default but untested
module swap gcc gcc/9.3.0

# Other modules required for the Fluidity build; not including petsc
#  as this will be built locally to include hypre
module load cray-python boost cmake trilinos

# Added environment for using system modules
export VTK_DIR=${FLUIDITY_PREFIX}/vtk
export VTK_INCLUDE=${VTK_DIR}/include/vtk-9.0
export VTK_LIBS="-L${VTK_DIR}/lib64 -lvtksys-9.0 -lvtkCommonCore-9.0 -lvtkCommonDataModel-9.0 -lvtkIOXML-9.0 -lvtkIOCore-9.0 -lvtkCommonExecutionModel-9.0 -lvtkParallelMPI-9.0 -lvtkIOLegacy-9.0 -lvtkFiltersVerdict-9.0 -lvtkIOParallelXML-9.0 -lvtkFiltersGeneral-9.0 -lvtkCommonTransforms-9.0 -lvtkCommonMath-9.0 -lvtkCommonMisc-9.0 -lvtkloguru-9.0 -lvtkCommonCore-9.0 -lvtksys-9.0 -lvtkverdict-9.0 -lvtkParallelCore-9.0 -lvtkCommonDataModel-9.0 -lvtkCommonMath-9.0 -lvtkCommonExecutionModel-9.0 -lvtkIOXMLParser-9.0 -lvtkexpat-9.0 -lvtkIOCore-9.0 -lvtkCommonCore-9.0 -lvtkIOLegacy-9.0 -lvtklz4-9.0 -lvtklzma-9.0 -lvtkzlib-9.0 -lvtkCommonCore-9.0 -lvtkdoubleconversion-9.0"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${SCOTCH_DIR}/lib:${CRAY_PYTHON_PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${TRILINOS_DIR}/lib"
export CPPFLAGS="${CPPFLAGS} -I${TRILINOS_DIR}/include -I${VTK_INCLUDE}"

# Make and change into a directory for building VTK
mkdir -p ${VTK_DIR}
pushd ${VTK_DIR}
  # Get VTK source
  curl -skL https://www.vtk.org/files/release/9.0/VTK-9.0.1.tar.gz | tar -zxf -
  # Make and change into a build directory
  mkdir ${VTK_DIR}/build
  pushd ${VTK_DIR}/build
    # Configure and build
    cmake -DBUILD_SHARED_LIBS=OFF -DVTK_USE_MPI=ON -DVTK_PYTHON_VERSION=3 -DCMAKE_INSTALL_PREFIX=${VTK_DIR} -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DVTK_WRAP_PYTHON=ON ../VTK-9.0.1
    make install
  popd
popd

# Modules required for the PETSc build
module load cray-hdf5-parallel/1.12.0.2 parmetis/4.0.3 metis/5.1.0 scotch/6.0.10 mumps/5.2.1 superlu/5.2.1 superlu-dist/6.1.1 hypre/2.18.0

# Extra environment for the PETSc build
export PETSC_INSTALL_DIR=${FLUIDITY_PREFIX}/petsc
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${PETSC_INSTALL_DIR}/lib"
export LDFLAGS="${LDFLAGS} -L${PETSC_INSTALL_DIR}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PETSC_INSTALL_DIR}/include"

# Make and change into a directory for building PETSc
mkdir -p ${PETSC_INSTALL_DIR}
pushd ${PETSC_INSTALL_DIR}
  # Get the PETSC source
  curl -fsL https://gitlab.com/petsc/petsc/-/archive/v3.13.3/petsc-v3.13.3.tar.gz | tar -zxf -
  # Change into the PETSc source directory to build
  pushd petsc-v3.13.3
    # Set PETSC_DIR for the build
    export PETSC_DIR=$PWD

   ./configure \
     --known-has-attribute-aligned=1 \
     --known-mpi-int64_t=0 \
     --known-bits-per-byte=8 \
     --known-64-bit-blas-indices=0 \
     --known-sdot-returns-double=0 \
     --known-snrm2-returns-double=0 \
     --known-level1-dcache-assoc=4 \
     --known-level1-dcache-linesize=64 \
     --known-level1-dcache-size=16384 \
     --known-memcmp-ok=1 \
     --known-mpi-c-double-complex=1 \
     --known-mpi-long-double=1 \
     --known-mpi-shared-libraries=0 \
     --known-sizeof-MPI_Comm=4 \
     --known-sizeof-MPI_Fint=4 \
     --known-sizeof-char=1 \
     --known-sizeof-double=8 \
     --known-sizeof-float=4 \
     --known-sizeof-int=4 \
     --known-sizeof-long-long=8 \
     --known-sizeof-long=8 \
     --known-sizeof-short=2 \
     --known-sizeof-size_t=8 \
     --known-sizeof-void-p=8 \
     --with-ar=ar \
     --with-batch=0 \
     --with-cc=cc \
     --with-clib-autodetect=0 \
     --with-cxx=CC \
     --with-cxxlib-autodetect=0 \
     --with-debugging=0 \
     --with-dependencies=0 \
     --with-fc=ftn \
     --with-fortran-interfaces=1 \
     --with-ranlib=ranlib \
     --with-scalar-type=real \
     --with-shared-ld=ar \
     --with-etags=0 \
     --with-x=0 \
     --with-ssl=0 \
     --with-shared-libraries=0 \
     --with-mpi-lib=[] \
     --with-mpi-include=[] \
     --with-mpiexec=srun \
     --with-blas-lapack=1 \
     --with-superlu=1 \
     --with-superlu_dist=1 \
     --with-parmetis=1 \
     --with-metis=1 \
     --with-scalapack=1 \
     --with-ptscotch=1 \
     --with-mumps=1 \
     --with-hypre=1 \
     --with-mumps-lib="-lmpifort" \
     --with-mumps-include="" \
     --with-hdf5=1 \
     F77=$F77 \
     F90=$F90 \
     CFLAGS="$CFLAGS $OMPFLAG" \
     CPPFLAGS="-I${PETSC_INSTALL_DIR}/include $CPPFLAGS" \
     CXXFLAGS="$CFLAGS $OMPFLAG" \
     --with-cxx-dialect=C++11 \
     FFLAGS="$FFLAGS $FOMPFLAG" \
     LDFLAGS="-L${PETSC_INSTALL_DIR}/lib $OMPFLAG $LDFLAGS" \
     LIBS="$PE_LIBS $LIBS -lstdc++" \
     PETSC_ARCH="$CRAY_CPU_TARGET" \
     --prefix=${PETSC_INSTALL_DIR}

     make all
     make install
  popd
popd

# Reset PETSC_DIR for the newly installed version
export PETSC_DIR=${PETSC_INSTALL_DIR}

# Make and change into a Fluidity build directory
mkdir -p ${FLUIDITY_PREFIX}
pushd ${FLUIDITY_PREFIX}
  # Get Fluidity source
  git clone https://github.com/fluidityproject/fluidity.git 
  pushd fluidity
    # Fixes for HDF5 1.12 in h5hut - remove when upstream is fixed
    sed -i -e 's/H5Oget_info(/H5Oget_info1(/' h5hut/test/testframe.c h5hut/src/h5core/private/h5_hdf5.c
    sed -i -e 's/H5Oget_info (/H5Oget_info1 (/' h5hut/src/h5core/private/h5_hdf5.h
    sed -i -e 's/H5Oget_info_by_name(/H5Oget_info_by_name1(/' h5hut/src/h5core/private/h5_hdf5.c
    # Fix for VTK9 - remove when upstream is fixed
    sed -i -e '/cmake/d' configure configure.in libadaptivity/configure libadaptivity/configure.in
    # Configure fluidity
    ./configure --enable-2d-adaptivity
    # Hack around broken libtool in libspud - couple of empty libraries not yet debugged
    sed -i -e 's/-l -l //' libspud/libtool
    # Compile fluidity
    make
    make fltools
  popd
popd
