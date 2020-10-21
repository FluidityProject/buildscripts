#!/bin/bash

# Set up initial environment
PREFIX=${SETLOCALPREFIX}
HELP2MAN_VERSION=1.47.12
HELP2MAN_SERVER=https://ftp.gnu.org/
HELP2MAN_SERVERDIR=gnu/help2man/
HELP2MAN_TARBALL=help2man-${HELP2MAN_VERSION}.tar.xz
HELP2MAN_BUILDROOT=${PREFIX}/builds/help2man/${HELP2MAN_VERSION}
HELP2MAN_SOURCEDIR=${HELP2MAN_BUILDROOT}/help2man-${HELP2MAN_VERSION}
HELP2MAN_BUILDDIR=${HELP2MAN_BUILDROOT}/help2man-${HELP2MAN_VERSION}-build
HELP2MAN_INSTALLDIR=${PREFIX}/tools/help2man/${HELP2MAN_VERSION}

# Archive any existing source tree
if [ -d ${HELP2MAN_BUILDROOT} ] ; then
  mv ${HELP2MAN_BUILDROOT} ${HELP2MAN_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${HELP2MAN_BUILDDIR}
mkdir -p ${HELP2MAN_INSTALLDIR}

# Fetch and unpack a new source
pushd ${HELP2MAN_BUILDROOT}
curl -s ${HELP2MAN_SERVER}${HELP2MAN_SERVERDIR}${HELP2MAN_TARBALL} | tar -Jxf -

# Change into the build directory
pushd ${HELP2MAN_BUILDDIR}

# Configure
${HELP2MAN_SOURCEDIR}/configure --prefix=${HELP2MAN_INSTALLDIR}

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
   ${HELP2MAN_INSTALLDIR}/build-help2man-${HELP2MAN_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules/help2man
cat > ${PREFIX}/modules/help2man/${HELP2MAN_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${HELP2MAN_INSTALLDIR}

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
