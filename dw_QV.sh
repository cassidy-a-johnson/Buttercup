#!/bin/bash

##This document hols the scripts to download the species genomes, raw reads, run Meryl, and run Merqury

##genomes download:
LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
echo $LINE
NAME=${LINE[0]}
ID=${LINE[1]}
URL=${LINE[2]}

mkdir -p ${ID}
cd ${ID}

sbatch --partition=vgl wget --no-check-certificate ${URL} 

##genomic data download:
