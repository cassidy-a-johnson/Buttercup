#!/bin/bash

##This is a working script to write the program for differentiating data types (illumina, hifi, 10x) for 2 parts of the script:
#1. Running Meryl
#2. The summary file

LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
echo $LINE
NAME=${LINE[0]}
ID=${LINE[1]}


#mkdir -p meryl

# Determining whether the genomic data directory has short reads or not (by type)
 if test -n "$(find ./genomic_data/10x/ -maxdepth 0 -empty)" ; then
    echo "No 10x genomic data"
else    
    sleep 10m
    echo "${ID} has 10x genomic data" > 10x
    cat 10x
    ls ./genomic_data/10x/*R*.fastq.gz > input.fofn
        sbatch --partition=vgl $STORE/bin/Merqury_QV_slurm/_submit_meryl2_10x_cj.sh 21 summary vgl 32 | awk '{print $4}' > meryl.id
fi

 if test -n "$(find ./genomic_data/pacbio_hifi/ -maxdepth 0  -empty)" ; then
    echo "No pacbio hifi data"
else  
    sleep 10m
    echo "${ID} has pacbio hifi genomic data" > Pacbio_hifi
    cat Pacbio_hifi
    ls ./genomic_data/pacbio_hifi/*.fastq.gz > R.fofn
        sbatch --partition=vgl $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R.fofn summary vgl | awk '{print $4}' > meryl.id
fi  

 if test -n "$(find ./genomic_data/illumina/ -maxdepth 0  -empty)" ; then
    echo "No iilumina genomic data"
else  
    sleep 10m
    echo "${ID} illumina genomic data" > Illumina
    cat Illumina
    ls ./genomic_data/illumina/*R1.fastq.gz > R1.fofn
    ls ./genomic_data/illumina/*R2.fastq.gz > R2.fofn
        sbatch --partition=vgl $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R1.fofn R2.fofn summary vgl | awk '{print $4}' > meryl.id
fi 


#Function: to create summary list of species and QV values among other features
Summary_list () {
    cat ${ID}_Merqury.qv > ../Summary_QV.file
if [ "$(ls -A 10x)" ]; then
    echo -n "   10x"
else echo "nope lol"
fi
if [ "$(ls -A Illumina)" ]; then
    echo -n "   Illumina"
fi
if [ "$(ls -A Pacbio_hifi)" ]; then
    echo -n "   Pacbio_Hifi"
fi
}