#!/bin/bash

##BUTTERCUP
##Here we sbatch dw_QV.sh

##The input file is formated by column with Species Name, Species ID, and Assembly FTP URL
##ex: Acanthisitta_chloris	bAcaChl1	https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/016/904/835/GCA_016904835.1_bAcaChl1.pri/GCA_016904835.1_bAcaChl1.pri_genomic.fna.gz

INPUTFILE=$1
num_files=$(wc -l ${INPUTFILE} | awk '{print $1}')
#Confirming the number of lines (jobs in the array) matches the input list

echo $num_files

#echo "\
#sbatch --partition=vgl --nice --array=1-${num_files}%1 --thread-spec=1 --exclude=node[141-165] $STORE/bin/Merqury_QV_slurm/dw_QV.sh ${INPUTFILE}"
#sbatch --partition=vgl --nice --array=1-${num_files}%5 --thread-spec=1 --exclude=node[141-165] $STORE/bin/Merqury_QV_slurm/dw_QV.sh ${INPUTFILE}
echo "\
sbatch --partition=vgl --nice --array=1-${num_files}%3 --thread-spec=1 --exclude=node[141-165] /lustre/fs5/vgl/store/cjohnson02/bin/Merqury_QV_slurm/buttercup_dw_QV.sh ${INPUTFILE}"
sbatch --partition=vgl --nice --array=1-${num_files}%3 --thread-spec=1 --exclude=node[141-165] /lustre/fs5/vgl/store/cjohnson02/bin/Merqury_QV_slurm/buttercup_dw_QV.sh ${INPUTFILE}


##3/22/23
##in order to limit how many jobs [genomes] in the array run at any given time:
##use the sbatch option --array
    # --array=1-150%5
        #run jobs 1-150 in an array, only running 5 at a time
    ##QUESTION: if i'm now limiting how many jobs run at once, do i still need to limit the nodes?
        #currently restricted to 5 nodes.