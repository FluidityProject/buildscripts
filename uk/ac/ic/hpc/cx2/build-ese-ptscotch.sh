#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese
PTSCOTCH_VERSION=6.0.3
PTSCOTCH_SERVER=http://gforge.inria.fr/
PTSCOTCH_SERVERDIR=frs/download.php/file/34618/
PTSCOTCH_TARBALL=scotch_${PTSCOTCH_VERSION}.tar.gz
PTSCOTCH_BUILDROOT=${PREFIX}/builds/ptscotch/${PTSCOTCH_VERSION}
PTSCOTCH_SOURCEDIR=${PTSCOTCH_BUILDROOT}/scotch_${PTSCOTCH_VERSION}
PTSCOTCH_INSTALLDIR=${PREFIX}/compilers/ese-ptscotch/${PTSCOTCH_VERSION}-${ESE_COMPILER}

# Archive any existing source tree
if [ -d ${PTSCOTCH_BUILDROOT} ] ; then
  mv ${PTSCOTCH_BUILDROOT} ${PTSCOTCH_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${PTSCOTCH_BUILDROOT}
mkdir -p ${PTSCOTCH_INSTALLDIR}

# Fetch and unpack a new source
pushd ${PTSCOTCH_BUILDROOT}
curl -s ${PTSCOTCH_SERVER}${PTSCOTCH_SERVERDIR}${PTSCOTCH_TARBALL} | tar -zxf -

# Change into the source directory
pushd ${PTSCOTCH_SOURCEDIR}/src

# Link the appropriate Make.inc

ln -s Make.inc/Makefile.inc.x86-64_pc_linux2.shlib Makefile.inc

# Build and install
prefix=${PTSCOTCH_INSTALLDIR} make
prefix=${PTSCOTCH_INSTALLDIR} make install

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
   ${PTSCOTCH_INSTALLDIR}/build-ese-ptscotch-${PTSCOTCH_VERSION}-${ESE_COMPILER}.sh

# Write module 

mkdir -p ${PREFIX}/modules/ese-ptscotch

cat > ${PREFIX}/modules/ese-ptscotch/${PTSCOTCH_VERSION}-${ESE_COMPILER} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${PTSCOTCH_INSTALLDIR}

module load mpi

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
