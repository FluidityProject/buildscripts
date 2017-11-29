#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese/software-cx2
GETTEXT_VERSION=0.19.8
GETTEXT_SERVER=https://ftp.gnu.org/
GETTEXT_SERVERDIR=pub/gnu/gettext/
GETTEXT_TARBALL=gettext-${GETTEXT_VERSION}.tar.gz
GETTEXT_BUILDROOT=${PREFIX}/builds/gettext/${GETTEXT_VERSION}
GETTEXT_SOURCEDIR=${GETTEXT_BUILDROOT}/gettext-${GETTEXT_VERSION}
GETTEXT_BUILDDIR=${GETTEXT_BUILDROOT}/gettext-${GETTEXT_VERSION}-build
GETTEXT_INSTALLDIR=${PREFIX}/tools/ese-gettext/${GETTEXT_VERSION}

# Archive any existing source tree
if [ -d ${GETTEXT_BUILDROOT} ] ; then
  mv ${GETTEXT_BUILDROOT} ${GETTEXT_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${GETTEXT_BUILDDIR}
mkdir -p ${GETTEXT_INSTALLDIR}

# Fetch and unpack a new source
pushd ${GETTEXT_BUILDROOT}
curl -s ${GETTEXT_SERVER}${GETTEXT_SERVERDIR}${GETTEXT_TARBALL} | tar -zxf -

# Change into the build directory
pushd ${GETTEXT_BUILDDIR}

# Configure
${GETTEXT_SOURCEDIR}/configure --prefix=${GETTEXT_INSTALLDIR}

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
   ${GETTEXT_INSTALLDIR}/build-ese-gettext-${GETTEXT_VERSION}.sh

# Write module 

mkdir ${PREFIX}/modules/ese-gettext
cat > ${PREFIX}/modules/ese-gettext/${GETTEXT_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${GETTEXT_INSTALLDIR}

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
