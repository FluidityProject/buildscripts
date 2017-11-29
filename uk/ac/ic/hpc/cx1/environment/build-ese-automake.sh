#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese/software-cx1
AUTOMAKE_VERSION=1.15
AUTOMAKE_SERVER=https://ftp.gnu.org/
AUTOMAKE_SERVERDIR=gnu/automake/
AUTOMAKE_TARBALL=automake-${AUTOMAKE_VERSION}.tar.gz
AUTOMAKE_BUILDROOT=${PREFIX}/builds/automake/${AUTOMAKE_VERSION}
AUTOMAKE_SOURCEDIR=${AUTOMAKE_BUILDROOT}/automake-${AUTOMAKE_VERSION}
AUTOMAKE_BUILDDIR=${AUTOMAKE_BUILDROOT}/automake-${AUTOMAKE_VERSION}-build
AUTOMAKE_INSTALLDIR=${PREFIX}/tools/ese-automake/${AUTOMAKE_VERSION}

# Archive any existing source tree
if [ -d ${AUTOMAKE_BUILDROOT} ] ; then
  mv ${AUTOMAKE_BUILDROOT} ${AUTOMAKE_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${AUTOMAKE_BUILDDIR}
mkdir -p ${AUTOMAKE_INSTALLDIR}

# Fetch and unpack a new source
pushd ${AUTOMAKE_BUILDROOT}
curl -s ${AUTOMAKE_SERVER}${AUTOMAKE_SERVERDIR}${AUTOMAKE_TARBALL} | tar -zxf -

# Change into the build directory
pushd ${AUTOMAKE_BUILDDIR}

# Configure
${AUTOMAKE_SOURCEDIR}/configure --prefix=${AUTOMAKE_INSTALLDIR}

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
   ${AUTOMAKE_INSTALLDIR}/build-ese-automake-${AUTOMAKE_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules/ese-automake

cat > ${PREFIX}/modules/ese-automake/${AUTOMAKE_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${AUTOMAKE_INSTALLDIR}

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF

# Set permissions

find $PREFIX -type d -exec chmod 755 '{}' \;
find $PREFIX -perm 700 -exec chmod 755 '{}' \;
find $PREFIX -perm 600 -exec chmod 644 '{}' \;
