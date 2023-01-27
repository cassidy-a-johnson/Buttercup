#!/bin/bash

##This is a working script to write the program for differentiating data types (illumina, hifi, 10x) for 2 parts of the script:

#1. WHICH PATH TO PROVIDE FOR MERYL
#2. WHICH MERYL TO RUN
    #check if a directory is empty (10x OR hifi illumina); so only check if 10x is empty
    #if 10x not empty then [remember to edit path in _submit_10x]
        #then run 10x meryl
    #if empty then readlink to absolute path
        #and run biuld meryl


#ls $VGP_PIPELINE/meryl2/
    #_submit_meryl2_10x.sh
    #_submit_meryl2_build.sh

##to find out if a directory is empty:

##assuming we are currently in ${ID} directory
##DIR="/genomic_data/10x"
##do i even need to make a variable here?


mkdir -p meryl

##NEED to create a path variable

# look for empty dir 
if [ "$(ls -A ./genomic_data/10x)" ]; then
    ls ./genomic_data/10x/*R1*.fastq.gz > R1.fofn
    ls ./genomic_data/10x/*R2*.fastq.gz > R2.fofn
        sbatch --partition=vgl --dependency="afterok:$(cat job.id)" $VGP_PIPELINE/meryl2/_submit_meryl2_10x.sh 21 R1.fofn R2.fofn ${meryl} mem=F vgl
elif [ "$(ls -A ./genomic_data/pacbio_hifi)" ]; then
    readlink -f /fAloSap1/genomic_data/pacbio_hifi > fAloSap1_abs_path.ls
    ls ./genomic_data/pacbio_hifi/*.fastq.gz > R.fofn
        sbatch --partition=vgl --dependency="afterok:$(cat job.id)" $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R.fofn output vgl
else
    readlink -f /fAloSap1/genomic_data/illumina > fAloSap1_abs_path.ls
    ls ./genomic_data/illumina/*R1.fastq.gz > R1.fofn
    ls ./genomic_data/illumina/*R2.fastq.gz > R2.fofn
        sbatch --partition=vgl --dependency="afterok:$(cat job.id)" $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R1.fofn R2.fofn summary mem=F vgl
fi      ##REMEMBER TO ADD THE SBATCH WHEN PUTTING IN DW_QV.SH

##NOTE: next step is add absolute path generation
##REMEMBER TO EDIT PATH INSIDE _submit_merl2_10x.sh


##Meryl tools to run:
##sbatch --partition=vgl --dependency="afterok:$(cat job.id)" ##CHANGE THIS $tools/meryl/scripts/_submit_meryl2_build_10x.sh 21 R1.fofn R2.fofn ${meryl} mem=F vgl
        #sbatch --partition=vgl --dependency="afterok:$(cat job.id)" $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R1.fofn R2.fofn ${meryl} mem=F vgl


##10x:
#$VGP_PIPELINE/meryl2/_submit_meryl2_10x.sh 21 R1.fofn R2.fofn ${meryl} mem=F vgl
##illumina:
#$VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R1.fofn R2.fofn ${meryl} mem=F vgl
##hifi:
#$VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R1.fofn ${meryl} mem=F vgl


##absolute path generation:
#readlink -f /lustre/fs4/home/cjohnson02/gnometools/fDreABH1/genomic_data/illumina *R1*.fastq.gz > meryl/R1.fofn
#[cjohnson02@login04 gnometools]$ readlink -f fDreABH1/genomic_data/
#/lustre/fs4/home/cjohnson02/gnometools/fDreABH1/genomic_data

#1. generate absolute path
#readlink -f /${ID}/genomic_data/illumina > ${ID}_abs_path
#readlink -f /${ID}/genomic_data/pacbio_hifi > ${ID}_abs_path
#2. print absolute 
#ABS_PATH=${${ID}_abs_path}
#ls ${ABS_PATH}/*R1.fastq.gz > R1.fofn
#ls ${ABS_PATH}/*R2.fastq.gz > R2.fofn
#ls ${ABS_PATH}/*.fastq.gz > R.fofn

#ls /genomic_data/10x/*R1*.fastq.gz > R1.fofn
#ls /genomic_data/10x/*R2*.fastq.gz > R2.fofn





#1/27/23
#This part of the script is to move the meryl output files (.meryl and .jid) and slurm.out
    #files to the meryl directory
    #this would come right after the meryl sbatch
    #there is no place to designate location of output in the _build_meryl script
mv *.meryl meryl
mv *.jid meryl
mv *.meryl.hist meryl
mv *.meryl.list meryl
#will leave .fofn in species directory
#will leave slurm_.out files in species directory

##THOUGHT: or should I move these after running Merqury?
    ##Or should I delete them like the raw reads when done?

#<output_prefix> = summary

##to run meryl statistics:
#/lustre/fs4/vgl/store/vglshare/tools/VGP-tools/meryl/Linux-amd64/bin/meryl statistics mem\=F.meryl | head