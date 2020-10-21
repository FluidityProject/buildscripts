#!/bin/bash

# Set up initial environment
PREFIX=${SETLOCALPREFIX}
FLUIDITY_GIT_URL=https://github.com/fluidityproject/fluidity.git
# Uncomment the following line if you want to get the latest version
#   as opposed to hardcoding a version to build
#FLUIDITY_VERSION=`git ls-remote https://github.com/fluidityproject/fluidity.git master | awk '{print substr($1,1,6);}'`
FLUIDITY_VERSION="51ed7ca"
FLUIDITY_SUFFIX="-009"
FLUIDITY_DEV_MODULE="fluidity-dev/20200730"
FLUIDITY_PYTHON_VERSION="python3.8"
FLUIDITY_BUILDROOT=${PREFIX}/builds/fluidity/${FLUIDITY_VERSION}${FLUIDITY_SUFFIX}
FLUIDITY_SOURCEDIR=${FLUIDITY_BUILDROOT}/fluidity-${FLUIDITY_VERSION}${FLUIDITY_SUFFIX}
FLUIDITY_BUILDDIR=${FLUIDITY_SOURCEDIR}
FLUIDITY_MODULEDIR=${PREFIX}/modules/fluidity/
FLUIDITY_INSTALLDIR=${PREFIX}/models/fluidity/${FLUIDITY_VERSION}${FLUIDITY_SUFFIX}
FLUIDITY_EXTRADIR=${PREFIX}/share/fluidity/

# Archive any existing source tree
if [ -d ${FLUIDITY_BUILDROOT} ] ; then
  mv ${FLUIDITY_BUILDROOT} ${FLUIDITY_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${FLUIDITY_BUILDDIR}
mkdir -p ${FLUIDITY_INSTALLDIR}

# Fetch and unpack a new source
pushd ${FLUIDITY_BUILDROOT}
git clone ${FLUIDITY_GIT_URL} fluidity-${FLUIDITY_VERSION}${FLUIDITY_SUFFIX}

# Change into the build directory
pushd ${FLUIDITY_BUILDDIR}
git reset --hard ${FLUIDITY_VERSION}

# Configure

export LIBS="${LIBS} -L${PETSC_DIR}/lib -lblas -llapack"

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
   ${FLUIDITY_INSTALLDIR}/build-fluidity-${FLUIDITY_VERSION}${FLUIDITY_SUFFIX}.sh

# Write module 

mkdir -p ${FLUIDITY_MODULEDIR}

cat > ${FLUIDITY_MODULEDIR}/${FLUIDITY_VERSION}${FLUIDITY_SUFFIX} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${FLUIDITY_INSTALLDIR}

module load ${FLUIDITY_DEV_MODULE}

setenv           FLUIDITY_HOME \${basedir}
prepend-path     PATH \${basedir}/bin 
prepend-path     PYTHONPATH \${basedir}/lib/${FLUIDITY_PYTHON_VERSION}/site-packages
prepend-path     LD_LIBRARY_PATH \${basedir}/lib 

EOF
