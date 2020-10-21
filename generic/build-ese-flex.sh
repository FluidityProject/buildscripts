#!/bin/bash

# Set up initial environment
PREFIX=${SETLOCALPREFIX}
FLEX_VERSION=2.6.4
FLEX_SERVER=https://codeload.github.com/
FLEX_SERVERDIR=westes/flex/tar.gz/
FLEX_TARBALL=v${FLEX_VERSION}
FLEX_BUILDROOT=${PREFIX}/builds/flex/${FLEX_VERSION}
FLEX_SOURCEDIR=${FLEX_BUILDROOT}/flex-${FLEX_VERSION}
FLEX_INSTALLDIR=${PREFIX}/tools/flex/${FLEX_VERSION}

# Archive any existing source tree
if [ -d ${FLEX_BUILDROOT} ] ; then
  mv ${FLEX_BUILDROOT} ${FLEX_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${FLEX_BUILDROOT}
mkdir -p ${FLEX_INSTALLDIR}

# Fetch and unpack a new source
pushd ${FLEX_BUILDROOT}
curl -s ${FLEX_SERVER}${FLEX_SERVERDIR}${FLEX_TARBALL} | tar -zxf -

# Flex builds in the source directory
pushd ${FLEX_SOURCEDIR}

${FLEX_SOURCEDIR}/autogen.sh
${FLEX_SOURCEDIR}/configure --prefix=${FLEX_INSTALLDIR}

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
   ${FLEX_INSTALLDIR}/build-flex-${FLEX_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules/flex

cat > ${PREFIX}/modules/flex/${FLEX_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${FLEX_INSTALLDIR}

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
