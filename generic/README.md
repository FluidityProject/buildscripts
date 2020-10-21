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

## Building a Fluidity supporting software stack

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

### Using the build scripts

Each script is intended to be self-contained, downloading source as required, and operating within
a 'prefix' directory set at the top of the script. Old builds are retained with timestamps as new
builds are started - be aware that in the case of larger packages this can use up a lot of space 
and files. 

The general structure of each script is:

* Define environment
* Fetch source
* Configure, build, and install
* Archive the build script
* Create a module

Some scripts contain subsidiary builds; for example, Zoltan is contained within the PETSc script,
to ensure that it makes direct use of sub-packages built by PETSc, and h5py is built from a
feedstock repository within the conda install.

As far as possible scripts are set up to run without user interaction, but in a few cases some
input may be needed to confirm dialogues - an example being the conda install.

Some scripts make assumptions about external environment being set, in particular where there are
interdependencies between packages. You are strongly advised to read through scripts and either
modify environment variables as required to suit your local system, or hard-code values if you 
prefer.

Builds are in general **not** optimised or tuned, to be as generic as possible, so you are very
much encouraged to modify configuration parameters to improve performance on your local system.
