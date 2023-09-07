#!/bin/bash

##sbatch script for bam2fastq species for BUTTERCUP

INPUTFILE=$1
num_files=$(wc -l ${INPUTFILE} | awk '{print $1}')
#Confirming the number of lines (jobs in the array) matches the input list

echo $num_files

echo "\
sbatch --partition=vgl --nice --array=1-${num_files}%2 --thread-spec=1 --exclude=node[141-165] /lustre/fs5/vgl/store/cjohnson02/bin/Merqury_QV_slurm/dw_bam.sh ${INPUTFILE}"
sbatch --partition=vgl --nice --array=1-${num_files}%2 --thread-spec=1 --exclude=node[141-165] /lustre/fs5/vgl/store/cjohnson02/bin/Merqury_QV_slurm/dw_bam.sh ${INPUTFILE}
