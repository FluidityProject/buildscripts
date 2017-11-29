#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese/software-cx2
TEXINFO_VERSION=6.3
TEXINFO_SERVER=https://ftp.gnu.org/
TEXINFO_SERVERDIR=gnu/texinfo/
TEXINFO_TARBALL=texinfo-${TEXINFO_VERSION}.tar.gz
TEXINFO_BUILDROOT=${PREFIX}/builds/texinfo/${TEXINFO_VERSION}
TEXINFO_SOURCEDIR=${TEXINFO_BUILDROOT}/texinfo-${TEXINFO_VERSION}
TEXINFO_BUILDDIR=${TEXINFO_BUILDROOT}/texinfo-${TEXINFO_VERSION}-build
TEXINFO_INSTALLDIR=${PREFIX}/tools/ese-texinfo/${TEXINFO_VERSION}

# Archive any existing source tree
if [ -d ${TEXINFO_BUILDROOT} ] ; then
  mv ${TEXINFO_BUILDROOT} ${TEXINFO_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${TEXINFO_BUILDDIR}
mkdir -p ${TEXINFO_INSTALLDIR}

# Fetch and unpack a new source
pushd ${TEXINFO_BUILDROOT}
curl -s ${TEXINFO_SERVER}${TEXINFO_SERVERDIR}${TEXINFO_TARBALL} | tar -zxf -

# Change into the build directory
pushd ${TEXINFO_BUILDDIR}

# Configure
${TEXINFO_SOURCEDIR}/configure --prefix=${TEXINFO_INSTALLDIR}

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
   ${TEXINFO_INSTALLDIR}/build-ese-texinfo-${TEXINFO_VERSION}.sh

# Write module 

mkdir ${PREFIX}/modules/ese-texinfo
cat > ${PREFIX}/modules/ese-texinfo/${TEXINFO_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${TEXINFO_INSTALLDIR}

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
