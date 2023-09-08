#!/bin/bash

##sbatch script for bam2fastq species for BUTTERCUP

LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))

echo $NAME
echo $TITLE
NAME=${LINE[0]}
TITLE=${LINE[1]}
ID=($(printf $TITLE | cut -d'_' -f 3 | cut -d'.' -f 1))
URL=${LINE[2]}

mkdir ${TITLE}
cd ${TITLE}



##Assembly download:
echo "\
sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=asm --output=%x_%A.out --wrap="wget --no-check-certificate ${URL}""
sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=asm --output=%x_%A.out --wrap="wget --no-check-certificate ${URL}"

#aws dwnld:
mkdir -p ./genomic_data/pacbio_hifi
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.bam" --include "*bam.pbi" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi


# generates out.fastq.gz
#bam2fastq -o out in_1.bam in_2.bam in_3.xml in_4.bam

#bam2fastq -o ${TITLE} *.bam




# generates in.bam.pbi
#pbindex in.bam