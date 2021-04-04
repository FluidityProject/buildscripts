#!/usr/bin/env bash

##############################################################################
#                                                                            #
#    Fluidity and supporting software environment for the MMM Young cluster  #
#                                                                            #
#    This is an evolving environment as the underlying system changes. The   #
#    latest version is available from the Fluidity buildscripts repository   #
#    at https://github.com/fluidityprohject/buildscripts in the uk/ac/ucl/rc #
#    directory. Please address any updates as pull requests to that repo.    #
#                                                                            #
##############################################################################

module unload default-modules apr gcc-libs
module load beta-modules
module load gcc-libs/9.2.0
module load compilers/gnu/9.2.0
module load mpi/openmpi/3.1.5/gnu-9.2.0
module load bison/3.0.4/gnu-4.9.2 flex/2.5.39 cmake/3.19.1 python/3.9.1

export PETSC_ARCH=linux-gnu-c-opt

## Set INSTALLDIR to the directory in scratch or home where 
##  the built softwar has been installed to.

export INSTALLDIR=

if [ -z "${INSTALLDIR}" ]; then
  echo "Please set INSTALLDIR before running"
  exit 0
fi

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

export PETSC_DIR=${INSTALLDIR}
