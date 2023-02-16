#!/bin/bash

##This document holds the scripts to download the species genomes, raw reads, run Meryl, and run Merqury


##Genomes download:
LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
echo $LINE
NAME=${LINE[0]}
ID=${LINE[1]}
URL=${LINE[2]}

mkdir -p ${ID}
cd ${ID}

sbatch --partition=vgl --wrap="wget --no-check-certificate ${URL}"


##Raw reads download:
mkdir -p ./genomic_data/10x ./genomic_data/illumina ./genomic_data/pacbio_hifi

#10x:
echo "/
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include *R1*.fastq.gz --include *R2*.fastq.gz s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ./genomic_data/10x | awk '{print $4}' > job.id"
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ./genomic_data/10x | awk '{print $4}' > job.id

#illumina:
echo "/
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include *R1.fastq.gz --include *R2.fastq.gz s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ./genomic_data/illumina | awk '{print $4}' > job.id"
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1.fastq.gz" --include "*R2.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ./genomic_data/illumina | awk '{print $4}' > job.id

#pacbio_hifi:
echo "/
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include *.fastq.gz s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi | awk '{print $4}' > job.id"
sbatch --partition=vgl aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi | awk '{print $4}' > job.id

##Meryl:
sleep 10m

mkdir -p meryl

sbatch --partition=vgl --thread-spec=32 --dependency="afterok:$(cat job.id)" $STORE/bin/Merqury_QV_slurm/meryl_data_type.sh 

##Merqury:
until 
find ./summary.meryl -maxdepth 0
do echo "Sleeping for 15 minutes."
sleep 15m
done
echo $?

sbatch --partition=vgl --thread-spec=32 --dependency="afterok:$(cat meryl.id)" --wrap="rm -dfrv ./genomic_data/"

sbatch --partition=vgl --thread-spec=32 --dependency="afterok:$(cat meryl.id)" --wrap="mv logs ./meryl/; mv *.jid ./meryl/; mv *.meryl.hist ./meryl/; mv *.meryl.list ./meryl/"

sbatch --partition=vgl --thread-spec=32 /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl *.fna.gz ${ID}_Merqury

until 
find ./${ID}_Merqury.qv -maxdepth 0
do echo "Sleeping for 5 minutes."
sleep 5m
done
echo $?

sbatch --partition=vgl --thread-spec=32 --wrap="rm -dfrv ./meryl/; rm -dv G*.meryl"

##Summary:
sbatch --partition=vgl --thread-spec=32 --wrap="sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/Species_summary_list.sh"