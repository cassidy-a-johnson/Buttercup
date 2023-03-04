#!/bin/bash

##THIS IS THE DOCUMENT WHERE I WILL SBATCH THE DW_QV.SH SCRIPT

##how lines are in the input file? should 1> the number of species entries

INPUTFILE=$1
num_files=$(wc -l ${INPUTFILE} | awk '{print $1}')

echo $num_files

echo "\
sbatch --partition=vgl --array=1-${num_files} --thread-spec=32 --nodes=8 $STORE/bin/Merqury_QV_slurm/dw_QV.sh ${INPUTFILE}"
sbatch --partition=vgl --array=1-${num_files} --thread-spec=32 --nodes=8 $STORE/bin/Merqury_QV_slurm/dw_QV.sh ${INPUTFILE}

#while read SPECIES ; do sh script.sh ${SPECIES} ; done < genomes.ls