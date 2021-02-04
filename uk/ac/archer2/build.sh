#!/usr/bin/env bash
# Initial buildscript for Archer2 - minimally tested, use at your own risk!
#
# Note that all supporting software bar VTK is available from system modules. There
# are currently no plans to support VTK as a system module, hence we have to build
# it locally.
# 
# Note that at runtime to use the Fluidity binary built by this module you will
# need to do at least the following environment setup:
# 
#   module restore -s PrgEnv-gnu
#   module swap gcc gcc/9.3.0
#   module load cray-python
#   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CRAY_PYTHON_PREFIX}/lib  

# Where Fluidity will be built - edit this to your preferred location
export FLUIDITY_PREFIX=${HOME}/fluidity

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

# Other modules required for the Fluidity build
module load cray-python boost cmake trilinos petsc

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
