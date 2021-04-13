#!/bin/bash -l

#########cori##################
# #SBATCH --job-name=CuO
# #SBATCH -N 10         #Number of nodes
# #SBATCH -A m1141     #or m1947 
# #SBATCH --ntasks-per-node=32 # Cores=68 #knl # Cores=32 #haswell # Cores=24 #edison
# #SBATCH -t 48:00:00  #Set time limit max 48h
# # #SBATCH -q regular   #regular or premium or scavenger
# #SBATCH -L SCRATCH   #Job requires $SCRATCH file system
# #SBATCH -C haswell   #haswell or knl or nothing for edison but ncores=24
# module load vasp
# MPIR="srun -n 320"
##############################

#########lbl##################
#SBATCH --job-name=GS8Li2
#SBATCH --partition=etna
#SBATCH --account=etna
#SBATCH --qos=normal
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24
#SBATCH --time=1:00:00

module purge
#module load siesta/3.2
module load VG-TD/2.0.1
#or
#module load vasp
ulimit -s unlimited
MPIR="mpirun siesta"

#############################


##########run vasp###########
cd $SLURM_SUBMIT_DIR

$MPIR < input.fdf > output.fdf
