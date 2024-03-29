#!/usr/bin/env bash

##############################################################################
#                                                                            #
#    Fluidity and supporting software build for IC HPC Clusters              #
#                                                                            #
#    This is an evolving build as the underlying system changes and the      #
#    latest version is available from the Fluidity buildscripts repository   #
#    at https://github.com/fluidityprohject/buildscripts in the uk/ac/ic/hpc #
#    directory. Please address any updates as pull requests to that repo.    #
#                                                                            #
##############################################################################

## Don't continue if there's an error during the build

set -e
set -o pipefail

## Set INSTALLDIR to an empty directory in scratch or home where
##  the built software will be installed to.

export INSTALLDIR=

if [ -z "${INSTALLDIR}" ]; then
  echo "Please set INSTALLDIR in this script before running"
  exit 0
fi

## Load system modules

module load mpi intel-suite/2019.4

export CC=mpicc
export CXX=mpicxx
export FC=mpif90
export F77=mpif77
export F90=mpif90

## Set up personal python

module load anaconda3/personal
anaconda-setup

## Set up build environment

export PETSC_ARCH=linux-gnu-c-opt

export LDFLAGS="${LDFLAGS} -L${INSTALLDIR}/lib -L${INSTALLDIR}/lib64"
export CPPFLAGS="${CPPFLAGS} -I${INSTALLDIR}/include"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${INSTALLDIR}/lib:${INSTALLDIR}/lib64
export PATH=$PATH:${INSTALLDIR}/bin
export PYVER=`python3 -c "import sys; version=\".\".join(map(str, sys.version_info[:2])); print(version)"`
export PYTHONPATH=${INSTALLDIR}/lib/python${PYVER}/site-packages:${INSTALLDIR}/lib64/python${PYVER}/site-packages

## Build hdf5

curl -L -k -s "https://www.hdfgroup.org/package/hdf5-1-10-6-tar-gz/?wpdmdl=14135&refresh=5e5d12fa8ca571583158010" | tar -zxf -

mkdir hdf5-build
pushd hdf5-build
  ../hdf5-1.10.6/configure --enable-fortran --enable-parallel --prefix=${INSTALLDIR}
  make -j 10
  make install
popd

## Build PETSc

git clone -b release https://gitlab.com/petsc/petsc.git petsc
pushd petsc
  git checkout v3.14.2
  export PETSC_DIR=$PWD
  ./configure --with-shared-libraries --with-debugging=0 --PETSC_ARCH=${PETSC_ARCH} --download-metis=1 --download-ml=1 --download-parmetis=1 --download-triangle=1 --download-ptscotch=1 --download-suitesparse=1 --download-ctetgen=1 --download-chaco=1 --download-scalapack=1 --download-fblaslapack=1 --download-blacs=1 --known-mpi-shared-libraries=1 --prefix=${INSTALLDIR} --with-fortran-interfaces=1 --with-zlib=1 --with-hdf5=1 --with-valgrind=1 --download-hypre=1 --with-hdf5-dir=${INSTALLDIR}
  make -j 10 all
  make install
popd

export PETSC_DIR=${INSTALLDIR}

## Build Zoltan

curl -fsL https://github.com/sandialabs/Zoltan/archive/v3.83.tar.gz | tar -zxvf -
mkdir zoltan-build
pushd zoltan-build
  FFLAGS="-fallow-argument-mismatch" ../Zoltan-3.83/configure --prefix=${INSTALLDIR} --libdir=${INSTALLDIR}/lib --enable-mpi --with-mpi-compilers --with-gnumake --enable-f90interface --enable-zoltan-cppdriver --disable-examples --with-parmetis --with-parmetis-libdir=${INSTALLDIR}/lib --with-parmetis-incdir=${INSTALLDIR}/include --with-scotch --with-scotch-libdir=${INSTALLDIR}/lib --with-scotch-incdir=${INSTALLDIR}/include
  make -j 10
  make install
popd

## Link blas and lapack libraries so libadaptivity finds them

pushd ${INSTALLDIR}/lib
  ln -s libfblas.a libblas.a
  ln -s libflapack.a liblapack.a
popd

## Build VTK

curl -fsL https://www.vtk.org/files/release/9.2/VTK-9.2.0.rc1.tar.gz | tar -zxf -
mkdir vtk-build
pushd vtk-build
  LDFLAGS="-lirc" cmake -DVTK_USE_MPI=ON -DVTK_PYTHON_VERSION=3 -DModule_vtkParallelMPI=ON -DCMAKE_INSTALL_PREFIX=${INSTALLDIR} -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DVTK_WRAP_PYTHON=ON ../VTK-9.2.0.rc1
  make -j 10
  make install
popd

## Build Fluidity

## Change the git URL to your own branch if required
git clone https://github.com/fluidityproject/fluidity.git

pushd fluidity
  ## Fixes for VTK9 cna be removed once fixed upstream
  git apply ../vtk9fixes.patch

  ## For some reason ltmain.sh (required by h5hut) is missing and
  ##  needs libtoolize rerunning
  libtoolize

  ## Apply the configure changes for VTK9
  autoconf
  pushd libadaptivity
    autoconf
  popd

  ## Configure misses that fblas and flapack from PETSc are interdependent
  ##  so specify this explicitly
  ./configure --enable-2d-adaptivity --with-blas="-lfblas -lflapack" --with-lapack="-lfblas -lflapack" --prefix=${INSTALLDIR}

  make install
  make install-diamond
  make install-user-schemata
popd
