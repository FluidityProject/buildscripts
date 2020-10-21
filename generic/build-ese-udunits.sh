#!/bin/bash

# Set up initial environment
PREFIX=${SETLOCALPREFIX}
UDUNITS_VERSION=1.12.11
UDUNITS_SERVER=https://www.unidata.ucar.edu/
UDUNITS_SERVERDIR=downloads/udunits/
UDUNITS_TARBALL=udunits-${UDUNITS_VERSION}.tar.gz
UDUNITS_BUILDROOT=${PREFIX}/builds/udunits/${UDUNITS_VERSION}
UDUNITS_SOURCEDIR=${UDUNITS_BUILDROOT}/udunits-${UDUNITS_VERSION}/src
UDUNITS_BUILDDIR=${UDUNITS_BUILDROOT}/udunits-build
UDUNITS_INSTALLDIR=${PREFIX}/tools/udunits/${UDUNITS_VERSION}

# Archive any existing source tree
if [ -d ${UDUNITS_BUILDROOT} ] ; then
  mv ${UDUNITS_BUILDROOT} ${UDUNITS_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${UDUNITS_BUILDROOT}
mkdir -p ${UDUNITS_INSTALLDIR}
mkdir -p ${UDUNITS_BUILDDIR}

# Fetch and unpack a new source
pushd ${UDUNITS_BUILDROOT}
curl -s ${UDUNITS_SERVER}${UDUNITS_SERVERDIR}${UDUNITS_TARBALL} | tar -zxf -

## UDUnits2 builds in an out-of-tree directory
#pushd ${UDUNITS_BUILDDIR}
#
#cmake -DCMAKE_INSTALL_PREFIX=${UDUNITS_INSTALLDIR} -DBUILD_TESTING=OFF ${UDUNITS_SOURCEDIR} 

pushd ${UDUNITS_SOURCEDIR}

./configure --prefix=${UDUNITS_INSTALLDIR}

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
   ${UDUNITS_INSTALLDIR}/build-udunits-${UDUNITS_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules/udunits

cat > ${PREFIX}/modules/udunits/${UDUNITS_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${UDUNITS_INSTALLDIR}

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 
append-path      --delim " " CPPFLAGS -I\${basedir}/include
append-path      --delim " " LDFLAGS -L\${basedir}/lib

EOF
