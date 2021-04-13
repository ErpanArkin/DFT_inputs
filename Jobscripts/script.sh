#!/bin/bash -l

#########cori##################
#SBATCH --job-name=CuO
#SBATCH -N 10         #Number of nodes
#SBATCH -A m1141     #or m1947 
#SBATCH --ntasks-per-node=32 # Cores=68 #knl # Cores=32 #haswell # Cores=24 #edison
#SBATCH -t 48:00:00  #Set time limit max 48h
# #SBATCH -q regular   #regular or premium or scavenger
#SBATCH -L SCRATCH   #Job requires $SCRATCH file system
#SBATCH -C haswell   #haswell or knl or nothing for edison but ncores=24
module load vasp
MPIR="srun -n 320"
##############################

#########lbl##################
# #SBATCH --job-name=GS8Li2
# #SBATCH --partition=etna
# #SBATCH --account=etna
# #SBATCH --qos=normal
# #SBATCH --nodes=10
# #SBATCH --ntasks-per-node=20
# #SBATCH --time=72:00:00
# 
# module purge
# module load intel openmpi mkl
# #or
# #module load vasp
# ulimit -s unlimited
# MPIR=mpirun

# # for NEB: 
# module load vasp
# $MPIR /global/home/groups-sw/nano/software/sl-7.x86_64/vasp.5.4.4_vtst/bin/vasp_std >> log
#############################


##########run vasp###########
cd $SLURM_SUBMIT_DIR

$MPIR vasp_gam >> log
