The script in this repository is intended to build a stack of supporting software on top of the base cluster software provided on IC HPC. You are recommended to run it in an interactive job, building on one of the cluster nodes. To start a interactive job for compilation, make sure you are connected to login-a (other login nodes don't allow interactive jobs to be started) with:

'''
ssh login-a.hpc.ic.ac.uk
'''

Then start an interactive job with:

'''
qsub -I -lwalltime=08:00:00 -lselect=1:ncpus=24:mem=48gb
'''

Using a node, you have access to fast local storage. Clone this repository onto the local disk:

'''
cd /tmp
git clone https://github.com/fluidityproject/buildscripts
'''

And change into the IC HPC directory:

'''
cd buildscripts/uk/ac/ic/hpc/
'''

Now edit the build script to set 'INSTALLDIR' to point to a directory on persistent storage - probably in your home directory - as the directory you're building in will only persist through the interactive job duration.

Finally, run the build script:

'''
./build.sh
'''
