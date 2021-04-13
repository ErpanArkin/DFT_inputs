#!/bin/bash -l

#########cori##################
#SBATCH -J cdft
#SBATCH -N 18         #Number of nodes
#SBATCH -A m1141     #or m1947 
#SBATCH -t 48:00:00  #Set time limit max 48h
#SBATCH --comment=96:00:00 
#SBATCH --time-min=2:00:00   #the minimum amount of time the job should run
#SBATCH -q flex   #regular or premium or scavenger or 
#SBATCH -C knl   #haswell or knl or nothing for edison but ncores=24
#SBATCH --ntasks-per-node=16 # Cores=68 #knl # Cores=32 #haswell
#SBATCH --core-spec=4  #for knl, leave 2 cores for the system
#SBATCH --signal=B:USR1@60
#SBATCH --requeue
#SBATCH --open-mode=append
#SBATCH --error=vtj-%j.err
#SBATCH --output=vtj-%j.out

module swap craype-haswell craype-mic-knl
module swap PrgEnv-intel PrgEnv-gnu
module load python3/3.7-anaconda-2019.07
export CRAYPE_LINK_TYPE=dynamic
source activate gpaw_knl

#source activate gpaw_haswell
export OMP_NUM_THREADS=1
MPIR="srun -n 288 -c 4 --cpu_bind=cores gpaw-python"
##############################
cd $SLURM_SUBMIT_DIR

$MPIR input.py > output.out &


# use the following three variables to specify the time limit per job (max_timelimit), 
# the amount of time (in seconds) needed for checkpointing, 
# and the command to use to do the checkpointing if any (leave blank if none)
max_timelimit=48:00:00   # can match the #SBATCH --time option but don't have to
ckpt_overhead=60         # should match the time in the #SBATCH --signal option
ckpt_command=

# requeueing the job if reamining time >0 (do not change the following 3 lines )
. /usr/common/software/variable-time-job/setup.sh
requeue_job func_trap USR1
wait
