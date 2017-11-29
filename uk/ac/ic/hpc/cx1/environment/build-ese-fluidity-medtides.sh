#!/bin/bash

# Set up initial environment
PREFIX=/home/software-ese/software-cx1
FLUIDITY_GIT_URL=https://github.com/fluidityproject/fluidity.git
FLUIDITY_GIT_BRANCH=Fluidity/fix/medTides
FLUIDITY_VERSION=`git ls-remote https://github.com/fluidityproject/fluidity.git ${FLUIDITY_GIT_BRANCH} | awk '{print substr($1,1,6);}'`
FLUIDITY_BUILDROOT=${PREFIX}/builds/fluidity/${FLUIDITY_VERSION}
FLUIDITY_SOURCEDIR=${FLUIDITY_BUILDROOT}/fluidity-${FLUIDITY_VERSION}
FLUIDITY_BUILDDIR=${FLUIDITY_SOURCEDIR}
FLUIDITY_INSTALLDIR=${PREFIX}/models/ese-fluidity/${FLUIDITY_VERSION}

# Archive any existing source tree
if [ -d ${FLUIDITY_BUILDROOT} ] ; then
  mv ${FLUIDITY_BUILDROOT} ${FLUIDITY_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${FLUIDITY_BUILDDIR}
mkdir -p ${FLUIDITY_INSTALLDIR}

# Fetch and unpack a new source
pushd ${FLUIDITY_BUILDROOT}
git clone ${FLUIDITY_GIT_URL} -b ${FLUIDITY_GIT_BRANCH} fluidity-${FLUIDITY_VERSION}

# Change into the build directory
pushd ${FLUIDITY_BUILDDIR}

# Configure
${FLUIDITY_SOURCEDIR}/configure --prefix=${FLUIDITY_INSTALLDIR} \
      --enable-2d-adaptivity

# Build and install
make && make fltools && make install

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
   ${FLUIDITY_INSTALLDIR}/build-ese-fluidity-${FLUIDITY_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules/ese-fluidity

cat > ${PREFIX}/modules/ese-fluidity/${FLUIDITY_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${FLUIDITY_INSTALLDIR}

module load ese-fluidity-dev

prepend-path     PATH \${basedir}/bin 
prepend-path     PYTHONPATH \${basedir}/lib/python2.7/site-packages
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
