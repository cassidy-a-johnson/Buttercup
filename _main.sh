#!/bin/bash

##BUTTERCUP
##Here we sbatch dw_QV.sh

##The input file is formated by column with Species Name, Species ID, and Assembly FTP URL
##ex: Acanthisitta_chloris	bAcaChl1	https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/016/904/835/GCA_016904835.1_bAcaChl1.pri/GCA_016904835.1_bAcaChl1.pri_genomic.fna.gz

INPUTFILE=$1
num_files=$(wc -l ${INPUTFILE} | awk '{print $1}')
#Confirming the number of lines (jobs in the array) matches the input list

echo $num_files

echo "\
sbatch --partition=vgl --nice --array=1-${num_files} --thread-spec=32 --nodes=8 $STORE/bin/Merqury_QV_slurm/dw_QV.sh ${INPUTFILE}"
sbatch --partition=vgl --nice --array=1-${num_files} --thread-spec=32 --nodes=8 $STORE/bin/Merqury_QV_slurm/dw_QV.sh ${INPUTFILE}