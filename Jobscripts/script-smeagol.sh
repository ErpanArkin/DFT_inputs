#!/bin/bash -l

#########cori##################
#SBATCH -J cdft
#SBATCH -N 4         #Number of nodes
#SBATCH -A m1141     #or m1947 
#SBATCH -t 48:00:00  #Set time limit max 48h
#SBATCH -q regular   #regular or premium or scavenger
#SBATCH -C knl   #haswell or knl or nothing for edison but ncores=24
# module load siesta/4.0.2
module load Smeagol/1.2
MPIR="srun -n 272 -c 4 --cpu_bind=cores smeagol.exe"
##############################

#########lbl##################
# #SBATCH --job-name=GS8Li2
# #SBATCH --partition=vulcan
# #SBATCH --account=vulcan
# #SBATCH --qos=normal
# #SBATCH --nodes=10
# #SBATCH --ntasks-per-node=8
# #SBATCH --time=72:00:00
# 
# module purge
# module load smeagol/1.2
# 
# ulimit -s unlimited
# #MPIR="mpirun smeagol.exe"
# MPIR="mpirun /global/home/users/yaierken/smeagol-lowdin/smeagol-1.2/Src/smeagol.exe"
#############################


##########run vasp###########
cd $SLURM_SUBMIT_DIR

$MPIR < input.fdf  >>  output.out

# Das' Smeagol
# $MPIR /project/projectdirs/mftheory/das-edison/smeagol-1.2/Src/smeagol.exe  < input.fdf  >>  output.out
