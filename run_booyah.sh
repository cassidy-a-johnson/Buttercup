#!/bin/bash

#This is a script to run booyah.sh [FOR MERQURY AND BEYOND]

INPUTFILE=$1
num_files=$(wc -l ${INPUTFILE} | awk '{print $1}')

echo "\
sbatch --partition=vgl --nice --array=1-${num_files} --thread-spec=1 /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/booyah.sh ${INPUTFILE}"
sbatch --partition=vgl --nice --array=1-${num_files} --thread-spec=1 /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/booyah.sh ${INPUTFILE}
