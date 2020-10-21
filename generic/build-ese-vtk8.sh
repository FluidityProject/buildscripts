#!/bin/bash

# Set up initial environment
PREFIX=${SETLOCALPREFIX}
VTK_MAJOR_VERSION=8
VTK_MINOR_VERSION=2
VTK_SUBMINOR_VERSION=0
VTK_VERSION=${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}.${VTK_SUBMINOR_VERSION}
VTK_SERVER=https://www.vtk.org/
VTK_SERVERDIR=files/release/${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}/
VTK_TARBALL=VTK-${VTK_VERSION}.tar.gz
VTK_BUILDROOT=${PREFIX}/builds/vtk/${VTK_VERSION}
VTK_SOURCEDIR=${VTK_BUILDROOT}/VTK-${VTK_VERSION}
VTK_BUILDDIR=${VTK_BUILDROOT}/vtk-build
VTK_INSTALLDIR=${PREFIX}/libraries/vtk/${VTK_VERSION}

# Archive any existing source tree
if [ -d ${VTK_BUILDROOT} ] ; then
  mv ${VTK_BUILDROOT} ${VTK_BUILDROOT}-`date +%s`
fi

# Make a new working directory for this version's build
mkdir -p ${VTK_BUILDROOT}
mkdir -p ${VTK_BUILDDIR}
mkdir -p ${VTK_INSTALLDIR}

# Fetch and unpack a new source
pushd ${VTK_BUILDROOT}
curl -skL ${VTK_SERVER}${VTK_SERVERDIR}${VTK_TARBALL} | tar -zxf -

# Flex builds in the source directory
pushd ${VTK_BUILDDIR}

cmake -DVTK_PYTHON_VERSION=3 -DModule_vtkParallelMPI=ON -DPYTHON_EXECUTABLE=${CONDA_PYTHON_EXE} -DPYTHON_INCLUDE_DIR=$CONDA_PREFIX/include/python3.7m -DPYTHON_LIBRARY=${CONDA_PREFIX}/lib/libpython3.7m.so -DPYTHON_UTIL_LIBRARY=/lib64/libutil.so.1 -DCMAKE_INSTALL_PREFIX=${VTK_INSTALLDIR} -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DVTK_WRAP_PYTHON=ON ${VTK_SOURCEDIR} 

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
   ${VTK_INSTALLDIR}/build-vtk-${VTK_VERSION}.sh

# Write module 

mkdir -p ${PREFIX}/modules/vtk

cat > ${PREFIX}/modules/vtk/${VTK_VERSION} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {

}

set basedir ${VTK_INSTALLDIR}

prepend-path     PATH \${basedir}/bin 
prepend-path     LD_LIBRARY_PATH \${basedir}/lib64 
setenv           VTK_INSTALL_PREFIX \${basedir}/include
setenv          VTK_HOME        \${basedir}
append-path     PATH \${basedir}/bin
append-path     LD_LIBRARY_PATH \${basedir}/lib64
append-path     PYTHONPATH \${basedir}/lib64/python3.7/site-packages/
append-path     CMAKE_MODULE_PATH \${basedir}/lib64/cmake
setenv          VTK_INCLUDE     \${basedir}/include/vtk-${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}
setenv          VTK_LIBS        \${basedir}/lib64



EOF

