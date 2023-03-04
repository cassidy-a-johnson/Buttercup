#!/bin/bash

##This document holds scripts to the download the raw reads of the assembled species differentiated by 10x, illumina, or pacbio_hifi reads

LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
echo $LINE
NAME=${LINE[0]}
ID=${LINE[1]}

cd ${ID}
mkdir -p ./genomic_data/10x ./genomic_data/illumina ./genomic_data/pacbio_hifi

#10x:
echo "/
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include *R1*.fastq.gz --include *R2*.fastq.gz s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ${ID}/genomic_data/10x | awk '{print $4}' > job.id"
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ${ID}/genomic_data/10x > joob.id

#illumina:
echo "/
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include *R1.fastq.gz --include *R2.fastq.gz s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ${ID}/genomic_data/illumina | awk '{print $4}' > job.id"
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1.fastq.gz" --include "*R2.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ${ID}/genomic_data/illumina | awk '{print $4}' > job.id

#pacbio_hifi:
echo "/
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include *.fastq.gz s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ${ID}/genomic_data/pacbio_hifi | awk '{print $4}' > job.id"
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ${ID}/genomic_data/pacbio_hifi | awk '{print $4}' > job.id
