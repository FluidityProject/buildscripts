#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese/software-cx2
MPC_VERSION=1.0.3
MPC_SERVER=ftp://ftp.gnu.org/
MPC_SERVERDIR=gnu/mpc/
MPC_TARBALL=mpc-${MPC_VERSION}.tar.gz
MPC_BUILDROOT=${PREFIX}/builds/mpc/${MPC_VERSION}
MPC_SOURCEDIR=${MPC_BUILDROOT}/mpc-${MPC_VERSION}
MPC_BUILDDIR=${MPC_BUILDROOT}/mpc-${MPC_VERSION}-build
MPC_INSTALLDIR=${PREFIX}/compilers/ese-mpc/${MPC_VERSION}

# Archive any existing source tree
if [ -d ${MPC_BUILDROOT} ] ; then
  mv ${MPC_BUILDROOT} ${MPC_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${MPC_BUILDDIR}
mkdir -p ${MPC_INSTALLDIR}

# Fetch and unpack a new source
pushd ${MPC_BUILDROOT}
curl -s ${MPC_SERVER}${MPC_SERVERDIR}${MPC_TARBALL} | tar -zxf -

# Change into the build directory
pushd ${MPC_BUILDDIR}

# Configure
${MPC_SOURCEDIR}/configure --prefix=${MPC_INSTALLDIR} \
         --with-gmp=${GMP_HOME} --with-mpfr=${MPFR_HOME}

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
   ${MPC_INSTALLDIR}/build-ese-mpc-${MPC_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules/ese-mpc
cat > ${PREFIX}/modules/ese-mpc/${MPC_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${MPC_INSTALLDIR}

module load mpi

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

setenv MPC_HOME ${MPC_INSTALLDIR}

EOF
