#!/bin/bash

##THIS IS THE DOCUMENT WHERE I WILL SBATCH THE DW_QV.SH SCRIPT

##how lines are in the input file? should 1> the number of species entries
num_files=$(wc -l ${1} | awk '{print $1}')

echo $num_files

##sbatch
##sbatch --partition=vgl --nodes=8 dw_QV.sh ${1}
    ##ASK GIULIO IF ANYTHING ELSE IS NEEDED