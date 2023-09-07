#!/bin/bash

#This is a script sbatch the error rate calculation script for kreeq

INPUTFILE=$1
num_files=$(wc -l ${INPUTFILE} | awk '{print $1}')

echo "\
sbatch --partition=vgl --nice --array=1-${num_files} --thread-spec=1 /rugpfs/fs0/vgl/store/cjohnson02/bin/kreeq_slurm/error_calc.sh ${INPUTFILE}"
sbatch --partition=vgl --nice --array=1-${num_files} --thread-spec=1 /rugpfs/fs0/vgl/store/cjohnson02/bin/kreeq_slurm/error_calc.sh ${INPUTFILE}
