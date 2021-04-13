#!/bin/bash -l

#########cori##################
#SBATCH -N 20         #Number of nodes
#SBATCH -A m1947     #or m1947 m1141
#SBATCH --ntasks-per-node=64 # Cores=68 #knl # Cores=32 #haswell # Cores=24 #edison
#SBATCH -t 48:00:00  #Set time limit max 48h
#SBATCH -q regular   #regular or premium or scavenger
#SBATCH -L SCRATCH   #Job requires $SCRATCH file system
#SBATCH -C knl   #haswell or knl or nothing for edison but ncores=24
#SBATCH --core-spec=4  #for knl, leave 2 cores for the system
module load vasp
MPIR="srun -n 1280 -c 4 --cpu_bind=cores "
DDEC_DIR="/global/homes/y/yaierken/software/chargemol_09_26_2017/atomic_densities/"
##############################

#########lbl##################
# #SBATCH --job-name=job
# #SBATCH --partition=vulcan
# #SBATCH --account=vulcan
# #SBATCH --qos=normal
# #SBATCH --nodes=5
# #SBATCH --ntasks-per-node=24
# #SBATCH --time=72:00:00
# 
# module purge
# module load vasp_intelmpi
# #or
# #module load vasp
# ulimit -s unlimited
# MPIR=mpirun
# DDEC_DIR="/global/home/users/yaierken/chargemol_09_26_2017/atomic_densities/"
#############################


##########run vasp###########
cd $SLURM_SUBMIT_DIR

cp POSCAR CONTCAR0
cp INCAR INCAR0
cp KPOINTS KPOINTS0
mv POSCAR CONTCAR
CONTCAR="`pwd`/CONTCAR"
c0=`awk 'NR == 5 {print $3}' $CONTCAR`;
for i in  `seq -w 1 1 5`; do

if [ $i -eq 2 ] || [ $i -eq 4 ] || [ $i -eq 5 ]
 then
 
c=`awk 'NR == 5 {print $3}' $CONTCAR`;
awk -v var=$c -v var0=$c0 'NR == 3 || NR == 4 {$3 = 0.0}; \
NR == 5 {$1 = 0.0; $2 = 0.0; $3 = var0}; \
NR > 8 && ( NF == 3  && /\./ && !/E+/ ) {$3 = $3*var/var0}; \
{if (NF == 3  && /\./ && !/E+/ ) {printf "%.16f %.16f %.16f\n", $1, $2, $3 } else {print $0}}' \
$CONTCAR > POSCAR
sed -i '/ISIF/s/ 4 / 2 /g' INCAR
else
  sed -i '/ISIF/s/ 2 / 4 /g' INCAR
  mv `pwd`/CONTCAR `pwd`/POSCAR
fi

sed -i '/IBRION/s/ -1 / 2 /g' INCAR
sed -i '/NSW/s/ 0 / 1000 /g' INCAR

if [ $i -eq 5 ]
  then
  sed -i '/IBRION/s/ 2 / -1 /g' INCAR
  sed -i '/NSW/s/1000/0/g' INCAR
  sed -i '/LCHARG/s/ .False. / .True. /g' INCAR
  sed -i '/LAECHG/s/ .False. / .True. /g' INCAR
  sed -i '/LVHAR/s/ .False. / .True. /g' INCAR
  sed -i '/LELF/s/ .False. / .True. /g' INCAR
  sed -i '/LORBIT/s/ 0 / 11 /g' INCAR
  sed -i -e '/^[ ]*ISMEAR/s/0/-5/g' INCAR
  sed -i '/PREC/s/ Normal/ Accurate/g' INCAR
  sed -i '/KPAR/c\' INCAR
  sed -i '/ALGO/s/Fast/Normal/g' INCAR
  awk 'NR==4{$1=$1+4;$2=$2+4;}1' KPOINTS > KPOINTS6;cp KPOINTS6 KPOINTS;
$MPIR vasp_std >> log
fi 

if [ $i -ne 5 ]
  then
$MPIR vasp_gam >> log
  cp `pwd`/CONTCAR `pwd`/CONTCAR"$i"
  cp `pwd`/OUTCAR `pwd`/OUTCAR"$i"
  cp `pwd`/OSZICAR `pwd`/OSZICAR"$i"
  cp `pwd`/POSCAR `pwd`/POSCAR"$i"
  cp `pwd`/vasprun.xml `pwd`/vasprun"$i".xml
  rm CHG CHGCAR DOSCAR EIGENVAL IBZKPT OSZICAR OUTCAR PCDAT POSCAR vasprun.xml WAVECAR XDATCAR
  fi
            

done

chgsum.pl AECCAR0 AECCAR2
bader CHGCAR -ref CHGCAR_sum

echo "

<net charge>
0.0
</net charge>

<periodicity along A, B, and C vectors>
.true.
.true.
.true.
</periodicity along A, B, and C vectors>

<atomic densities directory complete path>
$DDEC_DIR
</atomic densities directory complete path>

<charge type>
DDEC6
</charge type>

<compute BOs>
.true. 
</compute BOs>

" > job_control.txt

export OMP_NUM_THREADS=16

Chargemol_09_26_2017_linux_parallel

if [ $? == 0 ]
 then
 rm WAVECAR CHGCAR_sum AECC*
fi



mkdir bands; cd bands;
        
        cp ../INCAR .      
        sed -i '/ICHARG/s/2/11/g' INCAR
        #sed -i '/LWAVE/s/ .False. / .True. /g' INCAR
        sed -i '/LAECHG/s/ .True. / .False. /g' INCAR
        sed -i '/LVHAR/s/ .True. / .False. /g' INCAR
        sed -i -e '/^[ ]*ISMEAR/s/-5/0/g' INCAR
        sed -i '/LELF/s/ .True. / .False. /g' INCAR
        cp ../KPOINTS_band ./KPOINTS
        cp ../POTCAR .
        cp ../CONTCAR ./POSCAR
        cp ../CHGCAR .

        $MPIR vasp_std >> log

        rm CHGCAR  
        cd ..
mv INCAR0 INCAR
mv KPOINTS0 KPOINTS
