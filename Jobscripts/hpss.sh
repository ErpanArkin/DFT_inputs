#!/bin/bash

# move to the local scratch directory where the job will be run
cd $PWD

# define a shell variable with the current date in YYYY-MM-DD_HOUR:MINUTE:SECOND format
TODAY=$(date '+%Y-%m-%d_%H:%M:%S')

htar -cf scratch_$NERSC_HOST/scratch.$TODAY.tar .
hpssquota -u yaierken
#to check the tar file, run this on the cluster
#htar -tf scratch_$NERSC_HOST/{...}.tar

#to extact the tar file here, run this on the cluster
#htar -xf scratch_$NERSC_HOST/{...}.tar
