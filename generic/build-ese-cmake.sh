#!/bin/bash

# Set up initial environment
PREFIX=${SETLOCALPREFIX}
CMAKE_VERSION=3.17.1
CMAKE_SERVER=https://github.com/
CMAKE_SERVERDIR=kitware/CMake/releases/download/v${CMAKE_VERSION}/
CMAKE_TARBALL=cmake-${CMAKE_VERSION}.tar.gz
CMAKE_BUILDROOT=${PREFIX}/builds/cmake/${CMAKE_VERSION}
CMAKE_SOURCEDIR=${CMAKE_BUILDROOT}/cmake-${CMAKE_VERSION}
CMAKE_INSTALLDIR=${PREFIX}/tools/cmake/${CMAKE_VERSION}

# Archive any existing source tree
if [ -d ${CMAKE_BUILDROOT} ] ; then
  mv ${CMAKE_BUILDROOT} ${CMAKE_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${CMAKE_BUILDROOT}
mkdir -p ${CMAKE_INSTALLDIR}

# Fetch and unpack a new source
pushd ${CMAKE_BUILDROOT}
curl -skL ${CMAKE_SERVER}${CMAKE_SERVERDIR}${CMAKE_TARBALL} | tar -zxf -

# Flex builds in the source directory
pushd ${CMAKE_SOURCEDIR}

cmake -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALLDIR} -DCMAKE_USE_OPENSSL=OFF .

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
   ${CMAKE_INSTALLDIR}/build-cmake-${CMAKE_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules/cmake

cat > ${PREFIX}/modules/cmake/${CMAKE_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${CMAKE_INSTALLDIR}

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
