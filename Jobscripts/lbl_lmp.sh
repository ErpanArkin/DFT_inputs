#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Partition:
#SBATCH --partition=vulcan
#
# Processors:
#SBATCH --nodes=2
#SBATCH --exclusive
##SBATCH --ntasks-per-node=4
#
# Wall clock limit:
#SBATCH --time=01:00:00
#
# Mail type:
#SBATCH --mail-type=all
#
# Mail user:
#SBATCH --mail-user=yaierken@lbl.gov
#
## Run command
module load ms/lammps
mpirun lmp_mpi < in.bulk > log.bulk_SPC_my
