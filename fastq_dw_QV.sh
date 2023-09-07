#!/bin/bash

##This program contains scripts to download the species genomes, raw reads, run Meryl and Merqury, and organize outputs.
    ##This version is for species with PacBio Hifi short reads in the fastq format
##BUTTERCUP


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
sbatch --partition=vgl --nice --job-name=asm --output=%x_%A.out --wrap="wget --no-check-certificate ${URL}""
sbatch --partition=vgl --nice --job-name=asm --output=%x_%A.out --wrap="wget --no-check-certificate ${URL}"
echo "Assembly downloaded."


##Raw reads download:
mkdir -p ./genomic_data/10x ./genomic_data/illumina ./genomic_data/pacbio_hifi
echo "Downloading raw reads."

#10x:
echo "/
sbatch --partition=vgl --nice --thread-spec=8 --job-name=aws_10x --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ./genomic_data/10x | awk '{print $4}' >> 10x.id"
sbatch --partition=vgl --nice --thread-spec=8 --job-name=aws_10x --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ./genomic_data/10x | awk '{print $4}' >> 10x.id
#illumina:
echo "/
sbatch --partition=vgl --nice --thread-spec=8 --job-name=aws_illumina --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1.fastq.gz" --include "*R2.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ./genomic_data/illumina | awk '{print $4}' >> illumina.id"
sbatch --partition=vgl --nice --thread-spec=8 --job-name=aws_illumina --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1.fastq.gz" --include "*R2.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ./genomic_data/illumina | awk '{print $4}' >> illumina.id
#pacbio_hifi:
echo "/
sbatch --partition=vgl --nice --thread-spec=8 --job-name=aws_pacbiohifi --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" --include "*.fastq" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi | awk '{print $4}' >> hifi.id"
sbatch --partition=vgl --nice --thread-spec=8 --job-name=aws_pacbiohifi --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" --include "*.fastq" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi | awk '{print $4}' >> hifi.id

cat 10x.id illumina.id hifi.id >> jobs.id

job_nums=`wc -l jobs.id | awk '{print $1}'`

if [[ $job_nums -eq 1 ]]; then
   jid=`cat jobs.id`
   WAIT=$WAIT$jid
else
    for jid in $(cat jobs.id)
    do
        WAIT=$WAIT$jid","
    done
    WAIT=${WAIT::-1}
fi

echo "/
sbatch --partition=vgl --nice --dependency=afterok:$WAIT --job-name=reads_check --output=%x_%A.out --wrap=\"sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/dw_reads_check.sh\" | awk '{print $4}' > check.id"
sbatch --partition=vgl --nice --dependency=afterok:$WAIT --job-name=reads_check --output=%x_%A.out --wrap="sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/dw_reads_check.sh" | awk '{print $4}' > check.id


##Meryl:
mkdir -p meryl
echo "Running Meryl."

if test -n "$(find ./genomic_data/pacbio_hifi/ -maxdepth 0  -empty)" ; then
    echo "No pacbio hifi data."
else  
    echo "This species has pacbio hifi genomic data." > Pacbio_hifi
    cat Pacbio_hifi
    ls ./genomic_data/pacbio_hifi/*.fastq > R.fofn
    echo "/sbatch --partition=vgl --nice /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/_submit_meryl2_build_fastq.sh 21 R.fofn summary vgl | awk '{print $4}' >> transformer.id"
           sbatch --partition=vgl --nice /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/_submit_meryl2_build_fastq.sh 21 R.fofn summary vgl | awk '{print $4}' >> transformer.id
fi  


#Merqury:
wait_output() {
  local output="$1"; shift

  until [ -d $output ] ; do sleep 300; done
  
}
wait_output ./summary.meryl

echo "Running Merqury."
echo "/
sbatch --partition=vgl --nice --dependency=afterok:`cat transformer.id` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl *.fna.gz ${ID}_Merqury | awk '{print $4}' > Merqury.jid"
sbatch --partition=vgl --nice --dependency=afterok:`cat transformer.id` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl *.fna.gz ${ID}_Merqury | awk '{print $4}' > Merqury.jid

echo "Cleaning unnecessary files."
sbatch --partition=vgl --nice --job-name=rm_genomic_data --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="rm -dfrv ./genomic_data/"

sbatch --partition=vgl --nice --job-name=mv_meryl --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="mv logs ./meryl/; mv *.meryl.hist ./meryl/; mv *.meryl.list ./meryl/"

sbatch --partition=vgl --nice --job-name=rm_meryl_etc --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="rm -dfrv ./meryl/; rm -frdv *.meryl; rm *.dat; rm *.fastq.gz; rm *fna.gz"


##Summary:
echo "/
sbatch --partition=vgl --nice --dependency=afterok:`cat Merqury.jid` --job-name=Summary_generation --output=%x_%A.out --wrap="sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/Species_summary_list.sh""
sbatch --partition=vgl --nice --dependency=afterok:`cat Merqury.jid` --job-name=Summary_generation --output=%x_%A.out --wrap="sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/Species_summary_list.sh"
echo "Summary data loaded to table."