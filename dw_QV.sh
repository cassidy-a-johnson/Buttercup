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
mkdir -p ./genomic_data/10x ./genomic_data/illumina ./genomic_data/pacbio_hifi

#10x:
echo "/
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include *R1*.fastq.gz --include *R2*.fastq.gz s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ${ID}/genomic_data/10x | awk '{print $4}' > job.id"
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ${ID}/genomic_data/10x | awk '{print $4}' > job.id

#illumina:
echo "/
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include *R1.fastq.gz --include *R2.fastq.gz s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ${ID}/genomic_data/illumina | awk '{print $4}' > job.id"
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1.fastq.gz" --include "*R2.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ${ID}/genomic_data/illumina | awk '{print $4}' > job.id

#pacbio_hifi:
echo "/
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include *.fastq.gz s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ${ID}/genomic_data/pacbio_hifi | awk '{print $4}' > job.id"
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ${ID}/genomic_data/pacbio_hifi | awk '{print $4}' > job.id

##Meryl:
mkdir -p meryl

if [ "$(ls -A ./genomic_data/10x)" ]; then
    ls ./genomic_data/10x/*R1*.fastq.gz > R1.fofn
    ls ./genomic_data/10x/*R2*.fastq.gz > R2.fofn
        sbatch --partition=vgl --dependency="afterok:$(cat job.id)" $VGL0STORE/bin/Merqury_QV_slurm/_submit_meryl2_10x_cjohnson02.sh 21 R1.fofn R2.fofn ##CHANGE THIS BASED ON THE SCRIPT${meryl} vgl
elif [ "$(ls -A ./genomic_data/pacbio_hifi)" ]; then
    readlink -f /${ID}/genomic_data/pacbio_hifi > ${ID}_abs_path.ls
    ls ./genomic_data/pacbio_hifi/*.fastq.gz > R.fofn
        sbatch --partition=vgl --dependency="afterok:$(cat job.id)" $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R.fofn summary vgl
else
    readlink -f /${ID}/genomic_data/illumina > ${ID}_abs_path.ls
    ls ./genomic_data/illumina/*R1.fastq.gz > R1.fofn
    ls ./genomic_data/illumina/*R2.fastq.gz > R2.fofn
        sbatch --partition=vgl --dependency="afterok:$(cat job.id)" $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R1.fofn R2.fofn summary vgl
fi

mv *.meryl meryl
mv *.jid meryl
mv *.meryl.hist meryl
mv *.meryl.list meryl


##Merqury:
