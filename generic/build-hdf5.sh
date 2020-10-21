#!/bin/bash

# Set up initial environment
PREFIX=${SETLOCALPREFIX}
HDF5_VERSION_MAJOR="1"
HDF5_VERSION_MINOR="10"
HDF5_VERSION_SUBMINOR="6"
HDF5_VERSION=${HDF5_VERSION_MAJOR}.${HDF5_VERSION_MINOR}.${HDF5_VERSION_SUBMINOR}
HDF5_TARBALL="hdf5-${HDF5_VERSION}.tar.gz"
#HDF5_SERVER="https://s3.amazonaws.com/"
#HDF5_SERVERDIR="hdf-wordpress-1/wp-content/uploads/manual/HDF5/HDF5_${HDF5_VERSION_MAJOR}_${HDF5_VERSION_MINOR}_${HDF5_VERSION_SUBMINOR"

# Haven't worked out how to reverse engineer this sensibly...
HDF5_URL="https://www.hdfgroup.org/package/hdf5-1-10-6-tar-gz/?wpdmdl=14135&refresh=5e5d12fa8ca571583158010"

#HDF5_SERVER="https://support.hdfgroup.org/"
#HDF5_SERVERDIR="ftp/HDF5/releases/hdf5-1.8/hdf5-${HDF5_VERSION}/src/"
HDF5_BUILDROOT=${PREFIX}/builds/hdf5/${HDF5_VERSION}
HDF5_BUILDDIR=${HDF5_BUILDROOT}/hdf5-${HDF5_VERSION}-build
HDF5_SOURCEDIR=${HDF5_BUILDROOT}/hdf5-${HDF5_VERSION}
HDF5_INSTALLDIR=${PREFIX}/libraries/hdf5/${HDF5_VERSION}-${ESE_COMPILER}

# Archive any existing source trees
if [ -d ${HDF5_BUILDROOT} ] ; then
  mv ${HDF5_BUILDROOT} ${HDF5_BUILDROOT}-`date +%s`
fi

# Make new working directories for these versions' build
mkdir -p ${HDF5_BUILDDIR}

### HDF5 build
#
# Obtain source

pushd ${HDF5_BUILDROOT}
#curl -L -s ${HDF5_SERVER}${HDF5_SERVERDIR}${HDF5_TARBALL} | tar -zxf -
curl -L -k -s "${HDF5_URL}" | tar -zxf -

# Change into the build directory
pushd ${HDF5_BUILDDIR}

# Configure and build
${HDF5_SOURCEDIR}/configure --enable-fortran --enable-parallel --prefix=${HDF5_INSTALLDIR}

make install

# Return to our previous directory
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
   ${HDF5_INSTALLDIR}/build-hdf5-${HDF5_VERSION}-${ESE_COMPILER}.sh


# Write module 

mkdir -p ${PREFIX}/modules/hdf5

cat > ${PREFIX}/modules/hdf5/${HDF5_VERSION}-${ESE_COMPILER} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {
        global version

        puts stderr "\tHDF5 ${HDF5_VERSION}-${ESE_COMPILER} https://www.hdfgroup.org/downloads/hdf5/"
}

module-whatis   "HDF5 ${HDF5_VERSION}-${ESE_COMPILER} https://www.hdfgroup.org/downloads/hdf5/"


set basedir ${HDF5_INSTALLDIR} 

append-path PATH \${basedir}/bin
append-path MANPATH \${basedir}/share/man
append-path LD_LIBRARY_PATH \${basedir}/lib

# for Tcl script use only
setenv HDF5_HOME \${basedir}
setenv HDF5 \${basedir}
setenv HDF5HOME \${basedir}
setenv HDF5_VERSION ${HDF5_VERSION}-${ESE_COMPILER}
EOF
