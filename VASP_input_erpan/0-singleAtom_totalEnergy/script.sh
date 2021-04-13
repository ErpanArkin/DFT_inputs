#!/bin/bash

 # choose queue: qshort (1h), qreg (24h), qlong (72h), qxlong (168h)
#PBS -q qreg

 # "name" of the job (optional)
#PBS -N B-N-GeoRelax

 # requested running time (required!)
#PBS -l walltime=24:00:00

 # specification (required!)
 #   nodes=   number of nodes; 1 for serial; 1 or more for parallel
 #   ppn=     number of processors per node; 1 for serial; up to 8
 #   if you want your "private" node: ppn=8
 #   mem=     memory required
#PBS -l nodes=4:ppn=1:ib,pmem=1800mb

## if, in addition, you want to avoid that other (yours) jobs of you also could
## use this node, also add
# #PBS -l naccesspolicy=singlejob

 # send mail notification (optional)
 #   a        when job is aborted
 #   b        when job begins
 #   e        when job ends
 #   M        your e-mail address (should always be specified)
# #PBS -m e
# #PBS -M Yierpan.Aierken@student.uantwerpen.be

# go to the (current) working directory (optional, if this is the
# directory where you submitted the job)
cd $PBS_O_WORKDIR


# purge modules
module purge

# import VASP module
module load VASP/5.2.12-ictce-3.2.2.u2
# or the new one:
## module load VASP/5.3.3-ictce-4.0.1

# load mpiexec
module load mpiexec


for i in  `seq -w 1 1 4`; do

mpiexec vasp >> log

done

# for non collinear calculation:
## mpiexec vasp.noncollinear > log
