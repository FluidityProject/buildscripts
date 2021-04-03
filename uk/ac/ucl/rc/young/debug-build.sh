#!/usr/bin/env bash

##############################################################################
#                                                                            #
#    This is a debugging version of the build script, provisionally made     #
#    available to figure out problems with user installs. Please don't run   #
#    unless you've been asked to, as it may either not build, be out of      #
#    date, or behave in strange ways.                  -- TMBG, 2021/04/03   #
#                                                                            #
##############################################################################


##############################################################################
#                                                                            #
#    Fluidity and supporting software build for the MMM Young cluster        #
#                                                                            #
#    This is an evolving build as the underlying system changes and the      #
#    latest version is available from the Fluidity buildscripts repository   #
#    at https://github.com/fluidityprohject/buildscripts in the uk/ac/ucl/rc #
#    directory. Please address any updates as pull requests to that repo.    #
#                                                                            #
##############################################################################

##############################################################################
#                                                                            #
#                     IMPORTANT NOTE TO SAVE TIME!                           #
#                                                                            #
#    Don't run this script on one of the lustre mounts (home or scratch) as  #
#    these are optimised for large single file writes, not lots of small     #
#    writes. Run in /tmp or $TMPDIR, or your build will be VERY SLOW. Make   #
#    sure your installs go to permaenent storage, though (set INSTALLDIR).   #
#                                                                            #
##############################################################################

export STEP=0

## Don't continue if there's an error during the build

set -e

## Set INSTALLDIR to an empty directory in scratch or home where 
##  the built software will be installed to.

export INSTALLDIR=

date | tee -a ~/install.log

if [ -z "${INSTALLDIR}" ]; then
  echo "Please set INSTALLDIR in this script before running" | tee -a ~/install.log
  exit 0
else
  echo "INSTALLDIR set to ${INSTALLDIR}" | tee -a ~/install.log
fi

## Load system modules

echo "Modules prior to module load step" | tee -a ~/install.log
module list | tee -a ~/install.log

echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
module unload default-modules apr gcc-libs | tee -a ~/install.log
echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
module load beta-modules | tee -a ~/install.log
echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
module load gcc-libs/9.2.0 | tee -a ~/install.log
echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
module load compilers/gnu/9.2.0 | tee -a ~/install.log
echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
module load mpi/openmpi/3.1.5/gnu-9.2.0 | tee -a ~/install.log
echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
module load bison/3.0.4/gnu-4.9.2 flex/2.5.39 cmake/3.19.1 python/3.9.1 | tee -a ~/install.log

echo "Modules after module load step" | tee -a ~/install.log
echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
module list 2>&1 | tee -a ~/install.log

## Set up build environment


echo "Environment before build setup" >> ~/install.log
export >> ~/install.log

export PETSC_ARCH=linux-gnu-c-opt

export LDFLAGS="${LDFLAGS} -L${INSTALLDIR}/lib -L${INSTALLDIR}/lib64"
export CPPFLAGS="${CPPFLAGS} -I${INSTALLDIR}/include"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${INSTALLDIR}/lib:${INSTALLDIR}/lib64
export PATH=$PATH:${INSTALLDIR}/bin
export PYTHONPATH=${INSTALLDIR}/lib/python3.9/site-packages:${INSTALLDIR}/lib64/python3.9/site-packages

export CC=mpicc
export CXX=mpicxx
export FC=mpif90
export F77=mpif77
export F90=mpif90

echo "Environment after build setup" >> ~/install.log
export >> ~/install.log

## Install numpy

echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
python3 -m pip install -t $INSTALLDIR/lib/python3.9/site-packages numpy | tee -a ~/install.log

## Build Hypre standalone, as the PETSc build of HYPRE fails on Young

echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
curl -fsL https://github.com/hypre-space/hypre/archive/v2.20.0.tar.gz | tar -zxf - | tee -a ~/install.log
echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
pushd hypre-2.20.0/src/
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  ./configure --enable-shared --prefix=${INSTALLDIR} | tee -a ~/install.log 
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make install | tee -a ~/install.log
popd

## Build hdf5

echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
curl -L -k -s "https://www.hdfgroup.org/package/hdf5-1-10-6-tar-gz/?wpdmdl=14135&refresh=5e5d12fa8ca571583158010" | tar -zxf - | tee -a ~/install.log

echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
mkdir hdf5-build
pushd hdf5-build
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  ../hdf5-1.10.6/configure --enable-fortran --enable-parallel --prefix=${INSTALLDIR} | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make install | tee -a ~/install.log
popd

## Build PETSc

echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
git clone -b release https://gitlab.com/petsc/petsc.git petsc | tee -a ~/install.log
echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
git checkout v3.14.2 | tee -a ~/install.log
pushd petsc
  export PETSC_DIR=$PWD
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  ./configure --with-shared-libraries --with-debugging=0 --PETSC_ARCH=${PETSC_ARCH} --download-metis=1 --download-ml=1 --download-parmetis=1 --download-triangle=1 --download-ptscotch=1 --download-suitesparse=1 --download-ctetgen=1 --download-chaco=1 --download-scalapack=1 --download-fblaslapack=1 --download-blacs=1 --known-mpi-shared-libraries=1 --prefix=${INSTALLDIR} --with-fortran-interfaces=1 --with-zlib=1 --with-hdf5=1 --with-valgrind=1 --with-hypre=1 --with-hypre-dir=${INSTALLDIR} --with-hdf5-dir=${INSTALLDIR} | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make all | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make install | tee -a ~/install.log
popd

export PETSC_DIR=${INSTALLDIR}

## Build Zoltan

echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
curl -fsL https://github.com/sandialabs/Zoltan/archive/v3.83.tar.gz | tar -zxvf - | tee -a ~/install.log
echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
mkdir zoltan-build 
pushd zoltan-build
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  LDFLAGS="-lssp" ../Zoltan-3.83/configure --prefix=${INSTALLDIR} --libdir=${INSTALLDIR}/lib --enable-mpi --with-mpi-compilers --with-gnumake --enable-f90interface --enable-zoltan-cppdriver --disable-examples --with-parmetis --with-parmetis-libdir=${INSTALLDIR}/lib --with-parmetis-incdir=${INSTALLDIR}/include --with-scotch --with-scotch-libdir=${INSTALLDIR}/lib --with-scotch-incdir=${INSTALLDIR}/include | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make | tee -a ~/install.log 
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make install | tee -a ~/install.log
popd

## Link blas and lapack libraries so libadaptivity finds them

pushd ${INSTALLDIR}/lib
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  ln -s libfblas.a libblas.a | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  ln -s libflapack.a liblapack.a | tee -a ~/install.log
popd

## Build VTK

echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
curl -fsL https://www.vtk.org/files/release/9.0/VTK-9.0.1.tar.gz | tar -zxf - | tee -a ~/install.log
mkdir vtk-build 
pushd vtk-build
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  cmake -DVTK_USE_MPI=ON -DVTK_PYTHON_VERSION=3 -DModule_vtkParallelMPI=ON -DCMAKE_INSTALL_PREFIX=${INSTALLDIR} -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DVTK_WRAP_PYTHON=ON ../VTK-9.0.1 | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make install | tee -a ~/install.log
popd

## Build Fluidity

## Change the git URL to your own branch if required
echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
git clone https://github.com/fluidityproject/fluidity.git | tee -a ~/install.log

pushd fluidity
  ## Fixes for VTK9 cna be removed once fixed upstream
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  git apply ../vtk9fixes.patch | tee -a ~/install.log

  ## For some reason ltmain.sh (required by h5hut) is missing and
  ##  needs libtoolize rerunning
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  libtoolize | tee -a ~/install.log

  ## Apply the configure changes for VTK9
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  autoconf | tee -a ~/install.log
  pushd libadaptivity
    echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
    autoconf | tee -a ~/install.log
  popd

  ## Configure misses that fblas and flapack from PETSc are interdependent
  ##  so specify this explicitly
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  ./configure --enable-2d-adaptivity --with-blas="-lfblas -lflapack" --with-lapack="-lfblas -lflapack" --prefix=${INSTALLDIR} | tee -a ~/install.log

  ## Some unwanted mpi libraries end up being passed through from system
  ##  environment - prune these out of the build.
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  find . -name libtool -exec sed -i -e 's/-lmpi_usempif08 -lmpi_usempi_ignore_tkr//g' -e 's/-lgfortran//g' -e 's/-lquadmath//g' -e 's/-l //g' {} \; | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  find . -name Makefile -exec sed -i -e 's/-lmpi_usempif08 -lmpi_usempi_ignore_tkr//g' {} \; | tee -a ~/install.log

  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make install | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make install-diamond | tee -a ~/install.log
  echo "DEBUG: step ${STEP}" | tee -a ~/install.sh && ((STEP++))
  make install-user-schemata | tee -a ~/install.log
popd
