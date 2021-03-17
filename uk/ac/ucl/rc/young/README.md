This directory contains buildscripts for young.rc.ucl.ac.uk, an MMM cluster.

Documentation on using the cluster can be found at https://www.rc.ucl.ac.uk/docs/Clusters/Young/

To build Fluidity:

* Check out this repository to a temporary directory (ie, /tmp/<yourusername> on a head node), NOT to home or scratch
* Edit build.sh and set INSTALLDIR to an empty directory on home or scratch for installing Fluidity
* Run build.sh
* Wait on the order of three hours...

To set up the Fluidity runtime environment:

* Edit env.sh and set INSTALLDIR to the directory where Fluidity was installed (as used in build.sh)
* Source env.sh either in your interactive shell or your script

If you need additional python modules and want to install them into the Fluidity environment, use:

```bash
python3 -m pip install -t ${INSTALLDIR}/lib/python3.9/site-packages <module>
```

Note that this build and environment use some beta modules for gcc9 which may change as time passes - please report
any bugfixes back to this repo as pull requests - thank you!
