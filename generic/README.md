# Generic Fluidity install scripts

This directory contains a set of generic build scripts that are provided as a best-effort
attempt at supporting a Fluidity build on a minimal system where most or all supporting
software packages required by Fluidity are missing.

**In most cases this is not how you should aim to be installing Fluidity**

The majority of systems should be able to install Fluidity either using packages from your
distribution or by using pre-compiled modules available at a system-wide level. If you are
planning to install Fluidity using the scripts in this directory it is assumed that you are
familiar with and competent in building packages from source, and will be using these scripts
as guidance for builds, modifying them before they are run.

**Do not run any of these scripts without thoroughly reading through beforehand and editing
as required to suit your local system**

## Building Fluidity

Fluidity requires a set of supporting software packages to complete configuration and build.

If you are in doubt as to which packages are already present for Fluidity, a reasonable first
step is to read through, customise, and run the build-fluidity.sh script, and look at the output
from the configure step, with reference also to the generated config.log files in the root and
in package subdirectories.

### Key package requirements

The critical package requirements for Fluidity are listed here in the suggested build order:

* gcc/g++/gfortran (>=7)
* MPI 
* Python3 / Conda3
* PETSc (>=3.7)
* Zoltan (from Trilinos, with Fortran support)
* HDF5 (with parallel support, and h5py)
* VTK with python3 support

You are **strongly recommended** to use pre-existing packages wherever possible to minimise 
build effort and maximise the degree to which you can make use of support structures in place
for your local system. In particular, using system compilers and MPI is likely to be far more
optimal than a local build, and making use of system python overlaid with venvs as necessary
is likely to be a far cleaner option than maintaining your own python installation. 

Many high-end systems will already have optimised PETSc builds, and may also have optimised
Trilinos builds including Zoltan, though may be missing Fortran support which is required for
Fluidity. Similarly most high-end systems should have parallel HDF5 available, but may not 
have h5py available.

VTK tends to be the most problematic build if not already present, and if at all possible you
are recommended to use system packages to avoid a difficult build. Fluidity supports up to VTK8
and patches are available to support VTK9, either from the VTK9-fixes branch of Fluidity or from
the repository at https://github.com/tmbgreaves/ichpc-build-additional . VTK7 or later is required
to build against Python3.
