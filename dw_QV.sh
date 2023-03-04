#!/bin/bash

##This document holds the scripts to download the species genomes, raw reads, run Meryl and Merqury, and organize outputs.


##Genomes download:
LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
echo $NAME
echo $ID
NAME=${LINE[0]}
ID=${LINE[1]}
URL=${LINE[2]}

mkdir -p ${ID}
cd ${ID}

echo "/
sbatch --partition=vgl --job-name=asm --output=%.out --wrap="wget --no-check-certificate ${URL}""
sbatch --partition=vgl --job-name=asm --output=%x.out --wrap="wget --no-check-certificate ${URL}"
echo "Assembly downloaded."


##Raw reads download:
mkdir -p ./genomic_data/10x ./genomic_data/illumina ./genomic_data/pacbio_hifi
echo "Downloading raw reads."

#10x:
echo "/
sbatch --partition=vgl --wait --job-name=aws_10x --output=%x.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ./genomic_data/10x | awk '{printf $4 ", "}' >> 10x.id"
sbatch --partition=vgl --wait aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ./genomic_data/10x | awk '{printf $4 ", "}' >> 10x.id
#illumina:
echo "/
sbatch --partition=vgl --wait --job-name=aws_illumina --output=%x.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1.fastq.gz" --include "*R2.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ./genomic_data/illumina | awk '{printf $4 ", "}' >> illumina.id"
sbatch --partition=vgl --wait aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1.fastq.gz" --include "*R2.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ./genomic_data/illumina | awk '{printf $4 ", "}' >> illumina.id
#pacbio_hifi:
echo "/
sbatch --partition=vgl --wait --job-name=aws_pacbiohifi --output=%x.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" --include "*.fastq" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi | awk '{printf $4}' >> hifi.id"
sbatch --partition=vgl --wait aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" --include "*.fastq" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi | awk '{printf $4}' >> hifi.id

sbatch --partition=vgl --wait --job-name=cat_to_jobid --output=%x.out --dependency="afterany:10x.id,illumina.id,hifi.id" --wrap="cat 10x.id illumina.id hifi.id" >> job.id

echo"/
sbatch --partition=vgl --wait --job-name=reads_check --output=%x.out --wrap="sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/dw_reads_check.sh""
sbatch --partition=vgl --wait --job-name=reads_check --output=%x.out --wrap="sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/dw_reads_check.sh"

##Meryl:
mkdir -p meryl
echo "Running Meryl."
echo "/
sbatch --partition=vgl --wait --thread-spec=32 --job-name=Meryl --output=%x.out $STORE/bin/Merqury_QV_slurm/meryl_data_type.sh"
sbatch --partition=vgl --wait --thread-spec=32 --job-name=Meryl --output=%x.out $STORE/bin/Merqury_QV_slurm/meryl_data_type.sh


##Merqury:
wait_output() {
  local output="$1"; shift

  until [ -d $output ] ; do sleep 300; done
  
}
wait_output ./summary.meryl

echo "Running Merqury."
echo "/
sbatch --partition=vgl --wait --thread-spec=32 --job-name=Merqury --output=%x.out --dependency="afterok:$(cat transformer.id)" /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl *.fna.gz ${ID}_Merqury | awk '{print $4}' > Merqury.jid"
sbatch --partition=vgl --wait --thread-spec=32 --job-name=Merqury --output=%x.out --dependency="afterok:$(cat transformer.id)" /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl *.fna.gz ${ID}_Merqury | awk '{print $4}' > Merqury.jid

echo "Cleaning unnecessary files."
sbatch --partition=vgl --wait --job-name=rm_genomic_data --output=%x.out --dependency="afterok:$(cat transformer.id)" --wrap="rm -dfrv ./genomic_data/"

sbatch --partition=vgl --wait --job-name=mv_meryl --output=%x.out --dependency="afterok:$(cat transformer.id)" --wrap="mv logs ./meryl/; mv *.jid ./meryl/; mv *.meryl.hist ./meryl/; mv *.meryl.list ./meryl/"

sbatch --partition=vgl --wait --job-name=rm_meryl_etc --output=%x.out --dependency="afterok:$(cat transformer.id)" --wrap="rm -dfrv ./meryl/; rm -frdv *.meryl; rm *.dat; rm *.fastq.gz; rm *fna.gz"


##Summary:
echo "/
sbatch --partition=vgl --wait --job-name=Summary_generation --output=%x.out --wrap="sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/Species_summary_list.sh""
sbatch --partition=vgl --wait --job-name=Summary_generation --output=%x.out --wrap="sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/Species_summary_list.sh"
echo "Summary data loaded to table."