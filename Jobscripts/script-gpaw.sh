#!/bin/bash -l

#########cori##################
# #SBATCH -J cdft
# #SBATCH -N 4         #Number of nodes
# #SBATCH -A m1141     #or m1947 
# #SBATCH -t 48:00:00  #Set time limit max 48h
# #SBATCH -q regular   #regular or premium or scavenger
# #SBATCH -C knl   #haswell or knl or nothing for edison but ncores=24

# export CRAYPE_LINK_TYPE=dynamic
# module swap ${PE_ENV,,} PrgEnv-gnu/6.0.4
# #module swap craype-haswell craype-mic-knl
# module load python3/3.6-anaconda-4.4
# source activate gpaw_haswell  # or gpaw_knl
# export OMP_NUM_THREADS=1
# export MKL_CBWR="AVX"

# MPIR="srun -n 272 -c 4 --cpu_bind=cores"
##############################

#########lbl##################
#SBATCH --job-name=GS8Li2
#SBATCH --partition=nano1
#SBATCH --account=nano
#SBATCH --qos=normal
#SBATCH --nodes=4
# #SBATCH --ntasks-per-node=20
#SBATCH --time=2:00:00

module purge
module load gcc/6.3.0
module load mkl/2016.4.072  openmpi/3.0.1-gcc
module load python/3.6
source activate gpaw

MPIR="mpirun gpaw-python"
##############################

export OMP_NUM_THREADS=1

cd $SLURM_SUBMIT_DIR

$MPIR LiS8_cdft.py > LiS8_cdft.log
