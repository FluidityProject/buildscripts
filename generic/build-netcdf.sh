#!/bin/bash

# Set up initial environment
PREFIX=${SETLOCALPREFIX}
NETCDF_VERSION="4.7.3"
NETCDF_TARBALL="v${NETCDF_VERSION}.tar.gz"
NETCDF_SERVER="https://github.com/"
NETCDF_SERVERDIR="Unidata/netcdf-c/archive/"
NETCDF_BUILDROOT=${PREFIX}/builds/netcdf/${NETCDF_VERSION}
NETCDF_BUILDDIR=${NETCDF_BUILDROOT}/netcdf-${NETCDF_VERSION}-build
NETCDF_SOURCEDIR=${NETCDF_BUILDROOT}/netcdf-c-${NETCDF_VERSION}
NETCDF_INSTALLDIR=${PREFIX}/libraries/netcdf/${NETCDF_VERSION}-${ESE_COMPILER}
NETCDFF_VERSION="4.5.2"
NETCDFF_TARBALL="v${NETCDFF_VERSION}.tar.gz"
NETCDFF_SERVER="https://github.com/"
NETCDFF_SERVERDIR="Unidata/netcdf-fortran/archive/"
NETCDFF_BUILDDIR=${NETCDF_BUILDROOT}/netcdf-fortran-${NETCDF_VERSION}-build
NETCDFF_SOURCEDIR=${NETCDF_BUILDROOT}/netcdf-fortran-${NETCDFF_VERSION}

# Archive any existing source trees
if [ -d ${NETCDF_BUILDROOT} ] ; then
  mv ${NETCDF_BUILDROOT} ${NETCDF_BUILDROOT}-`date +%s`
fi

# Make new working directories for these versions' build
mkdir -p ${NETCDF_BUILDDIR}
mkdir -p ${NETCDFF_BUILDDIR}

### NetCDF-C build
#
# Obtain source

pushd ${NETCDF_BUILDROOT}
curl -L ${NETCDF_SERVER}${NETCDF_SERVERDIR}${NETCDF_TARBALL} | tar -zxf -

# Change into the build directory
pushd ${NETCDF_BUILDDIR}

# Configure and build
FC=mpif90 CC=mpicc LDFLAGS="-L${HDF5_HOME}/lib" \
   CPPFLAGS="-I${HDF5_HOME}/include" \
   LIBS="-L${HDF5_HOME}/lib" \
   ${NETCDF_SOURCEDIR}/configure --prefix=${NETCDF_INSTALLDIR}

make install

# Return to our previous directory
popd

### NetCDF-Fortran build
#
# Obtain source
curl -L ${NETCDFF_SERVER}${NETCDFF_SERVERDIR}${NETCDFF_TARBALL} | tar -zxf -

# Change into the source directory
pushd ${NETCDFF_BUILDDIR}

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_INSTALLDIR}/lib

# Configure and build
FC=mpif90 LDFLAGS="-L${NETCDF_INSTALLDIR}/lib -L${HDF5_HOME}/lib" \
   CPPFLAGS="-I${NETCDF_INSTALLDIR}/include -I${HDF5_HOME}/include" \
   LIBS="-L${NETCDF_INSTALLDIR}/lib -L${HDF5_HOME}/lib" \
   ${NETCDFF_SOURCEDIR}/configure --prefix=${NETCDF_INSTALLDIR}

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
   ${NETCDF_INSTALLDIR}/build-netcdf-${NETCDF_VERSION}-${ESE_COMPILER}.sh


# Write module 

mkdir -p ${PREFIX}/modules/netcdf

cat > ${PREFIX}/modules/netcdf/${NETCDF_VERSION}-${ESE_COMPILER} << EOF
#%Module1.0#####################################################################
##
## null modulefile
##
proc ModulesHelp { } {
        global version

        puts stderr "\tNetCDF ${NETCDF_VERSION}-${ESE_COMPILER} http://www.unidata.ucar.edu/downloads/netcdf/netcdf-${NETCDF_VERSION}-${ESE_COMPILER}/index.jsp"
}

module-whatis   "NetCDF ${NETCDF_VERSION}-${ESE_COMPILER} http://www.unidata.ucar.edu/downloads/netcdf/netcdf-${NETCDF_VERSION}-${ESE_COMPILER}/index.jsp"


set basedir ${NETCDF_INSTALLDIR} 

append-path PATH \${basedir}/bin
append-path MANPATH \${basedir}/share/man
append-path LD_LIBRARY_PATH \${basedir}/lib

# for Tcl script use only
setenv NETCDF_HOME \${basedir}
setenv NETCDF \${basedir}
setenv NETCDFHOME \${basedir}
setenv NETCDF_VERSION ${NETCDF_VERSION}-${ESE_COMPILER}
EOF
