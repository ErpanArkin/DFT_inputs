#!/bin/bash -l

#########cori##################
# #SBATCH --job-name=CuO
# #SBATCH -N 10         #Number of nodes
# #SBATCH -A m1141     #or m1947 
# #SBATCH --ntasks-per-node=68 # Cores=68 #knl # Cores=32 #haswell # Cores=24 #edison
# #SBATCH -t 48:00:00  #Set time limit max 48h
# # #SBATCH -q regular   #regular or premium or scavenger
# #SBATCH -L SCRATCH   #Job requires $SCRATCH file system
# #SBATCH -C knl   #haswell or knl or nothing for edison but ncores=24
# module load vasp
# MPIR="srun -n 680"
##############################

#########lbl##################
#SBATCH --job-name=GS8Li2
#SBATCH --partition=etna
#SBATCH --account=etna
#SBATCH --qos=normal
#SBATCH --nodes=15
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00

module purge
#module load intel openmpi mkl
#or
module load vasp
ulimit -s unlimited
MPIR=mpirun
#############################


##########run vasp###########
cd $SLURM_SUBMIT_DIR

mkdir 0;cp {INCAR,KPOINTS,POSCAR,POTCAR} 0/;
cd 0
$MPIR vasp_gam >> log
cat OUTCAR >> ../OUTCAR
cat XDATCAR >> ../XDATCAR
cat OSZICAR >> ../OSZICAR
cd ..


for i in `seq 10`;do mkdir $i;

cp {INCAR,KPOINTS,POTCAR} "$i"/
cp `expr $i - 1`/{CONTCAR,WAVECAR} "$i"/
mv "$i"/CONTCAR "$i"/POSCAR
cd $i
$MPIR vasp_gam >> log
cat OUTCAR >> ../OUTCAR
cat XDATCAR >> ../XDATCAR
cat OSZICAR >> ../OSZICAR
cd ..

done

LC_ALL=C fgrep  "Total+kin" OUTCAR > total+kin.dat
