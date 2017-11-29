#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese/software-cx2
MPFR_VERSION=3.1.5
MPFR_SERVER=http://www.mpfr.org/
MPFR_SERVERDIR=mpfr-current/
MPFR_TARBALL=mpfr-${MPFR_VERSION}.tar.xz
MPFR_BUILDROOT=${PREFIX}/builds/mpfr/${MPFR_VERSION}
MPFR_SOURCEDIR=${MPFR_BUILDROOT}/mpfr-${MPFR_VERSION}
MPFR_BUILDDIR=${MPFR_BUILDROOT}/mpfr-${MPFR_VERSION}-build
MPFR_INSTALLDIR=${PREFIX}/compilers/ese-mpfr/${MPFR_VERSION}

# Archive any existing source tree
if [ -d ${MPFR_BUILDROOT} ] ; then
  mv ${MPFR_BUILDROOT} ${MPFR_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${MPFR_BUILDDIR}
mkdir -p ${MPFR_INSTALLDIR}

# Fetch and unpack a new source
pushd ${MPFR_BUILDROOT}
curl -s ${MPFR_SERVER}${MPFR_SERVERDIR}${MPFR_TARBALL} | tar -Jxf -

# Change into the build directory
pushd ${MPFR_BUILDDIR}

# Configure
${MPFR_SOURCEDIR}/configure --prefix=${MPFR_INSTALLDIR} \
         --with-gmp=${GMP_HOME}

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
   ${MPFR_INSTALLDIR}/build-ese-mpfr-${MPFR_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules/ese-mpfr
cat > ${PREFIX}/modules/ese-mpfr/${MPFR_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${MPFR_INSTALLDIR}

module load mpi

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

setenv MPFR_HOME ${MPFR_INSTALLDIR}

EOF
