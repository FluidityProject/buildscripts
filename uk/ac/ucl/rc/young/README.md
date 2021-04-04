This directory contains buildscripts for young.rc.ucl.ac.uk, an MMM cluster.

Documentation on using the cluster can be found at https://www.rc.ucl.ac.uk/docs/Clusters/Young/

To build Fluidity:

* Check out this repository to a temporary directory (ie, /tmp/<yourusername> on a head node), NOT to home or scratch
* Edit build.sh and set INSTALLDIR to an empty directory on home or scratch for installing Fluidity
* Run build.sh
* Wait on the order of three hours...

If you're expecting or experiencing problems with the build and want to submit a bug report, please use 'debug-build.sh'
rather than build.sh. This is functionally identical to build.sh in terms of build steps and output, but generates a lot
more debugging output which is copied to ~/install.log which can be included with a bug report to aid debugging.

To set up the Fluidity runtime environment:

* Edit env.sh and set INSTALLDIR to the directory where Fluidity was installed (as used in build.sh)
* Source env.sh either in your interactive shell or your script, ie:

```bash
source env.sh
```

If you need additional python modules and want to install them into the Fluidity environment, use:

```bash
python3 -m pip install -t ${INSTALLDIR}/lib/python3.9/site-packages <module>
```

Note that this build and environment use some beta modules for gcc9 which may change as time passes - please report
any bugfixes back to this repo as pull requests - thank you!

To-do list:

* Get GCC10 support fixed in main branch
* Rebase this build/environment on GCC10 modules
* Raise issues for hdf5 (parallel), PETSc, Zoltan, blas/lapack, and VTK modules based on GCC10
