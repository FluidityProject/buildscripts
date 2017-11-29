#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese/software-cx1
SPUD_BZR_URL=lp:spud
SPUD_VERSION=`bzr revno lp:spud`
SPUD_BUILDROOT=${PREFIX}/builds/spud/${SPUD_VERSION}
SPUD_SOURCEDIR=${SPUD_BUILDROOT}/spud-${SPUD_VERSION}
SPUD_BUILDDIR=${SPUD_SOURCEDIR}
SPUD_INSTALLDIR=${PREFIX}/tools/ese-spud/${SPUD_VERSION}

# Archive any existing source tree
if [ -d ${SPUD_BUILDROOT} ] ; then
  mv ${SPUD_BUILDROOT} ${SPUD_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${SPUD_BUILDDIR}
mkdir -p ${SPUD_INSTALLDIR}

# Fetch and unpack a new source
pushd ${SPUD_BUILDROOT}
bzr co ${SPUD_BZR_URL} spud-${SPUD_VERSION}

# Change into the build directory
pushd ${SPUD_BUILDDIR}

# Configure
${SPUD_SOURCEDIR}/configure --prefix=${SPUD_INSTALLDIR}

# Build and install
make && make && make install

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
   ${SPUD_INSTALLDIR}/build-ese-spud-${SPUD_VERSION}.sh

# Fix permissions

find ${SPUD_INSTALLDIR} -perm 700 -exec chmod 755 '{}' \;
find ${SPUD_INSTALLDIR} -perm 1700 -exec chmod 755 '{}' \;
find ${SPUD_INSTALLDIR} -perm 2700 -exec chmod 755 '{}' \;
find ${SPUD_INSTALLDIR} -perm 4700 -exec chmod 755 '{}' \;
find ${SPUD_INSTALLDIR} -perm 600 -exec chmod 644 '{}' \;
find ${SPUD_INSTALLDIR} -perm 1600 -exec chmod 644 '{}' \;
find ${SPUD_INSTALLDIR} -perm 2600 -exec chmod 644 '{}' \;
find ${SPUD_INSTALLDIR} -perm 4600 -exec chmod 644 '{}' \;

# Write module 

mkdir -p ${PREFIX}/modules/ese-spud

cat > ${PREFIX}/modules/ese-spud/${SPUD_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${SPUD_INSTALLDIR}

prepend-path     PATH \${basedir}/bin 
prepend-path     PYTHONPATH \${basedir}/lib64/python2.7/site-packages
prepend-path     PYTHONPATH \${basedir}/lib/python2.7/site-packages
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
