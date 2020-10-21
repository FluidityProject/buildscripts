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
