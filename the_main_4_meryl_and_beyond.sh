#!/bin/bash

##BUTTERCUP
##Here we sbatch meryl_and_beyond.sh


echo "\
sbatch --partition=vgl --nice --thread-spec=1 --exclude=node[141-165] /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/meryl_and_beyond.sh"
sbatch --partition=vgl --nice --thread-spec=1 --exclude=node[141-165] /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/meryl_and_beyond.sh
