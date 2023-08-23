#!/bin/bash
#SBATCH --job-name=iDEDM_DES
#SBATCH -p eubd
#SBATCH -o ./projects/coupled_de_desy3/logs/%x_%A_%a.out
#SBATCH -e ./projects/coupled_de_desy3/logs/%x_%A_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=6
#SBATCH --mail-type=ALL
#SBATCH --mail-user=joao.reboucas@unesp.br
#SBATCH -t 6-23:00:00

yaml_file=./projects/coupled_de_desy3/yamls/MCMC${SLURM_ARRAY_TASK_ID}.yaml

echo "##################### JOB INFORMATION ############################"
echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo Slurm job NAME is $SLURM_JOB_NAME
echo Slurm job ID is $SLURM_JOBID

cd $SLURM_SUBMIT_DIR

module load anaconda3/2020.11
echo "ACTIVATING GLOBAL ENVIRONMENT"
source activate /scratch/eubd/joao.reboucas/.envs/cocoapy38
echo "ACTIVATING PRIVATE ENVIRONMENT"
source start_cocoa
export OMP_PROC_BIND=close
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
echo "STARTING CHAIN"

mpirun -n ${SLURM_NTASKS} --bind-to core --rank-by core --map-by numa:pe=${OMP_NUM_THREADS} cobaya-run $yaml_file -r --minimize

echo "CHAIN FINISHED"
source stop_cocoa
conda deactivate
module unload anaconda3/2020.11
