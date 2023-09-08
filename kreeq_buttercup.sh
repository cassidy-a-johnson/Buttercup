#!/bin/bash

##BUTTERCUP

##This program is designed to download the assembly and genomic data of a species, then calculate the QV (Quality Value) score 
##      of the species assembly using Meryl and Merqury and organizes outputs.


LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
NAME=${LINE[0]}
#ID=${LINE[1]}
TITLE=${LINE[1]}
ID=($(printf $TITLE | cut -d'_' -f 3 | cut -d'.' -f 1))
URL=${LINE[2]}
echo $NAME
echo $TITLE
echo $ID
echo $URL
#PARTITION=${LINE[3]}
#echo $PARTITION

#mkdir -p ${ID}
#cd ${ID}

##if there are paternal and maternal haplotypes, I recommend using titles such as bGalGal1.pat to keep track of species samples
mkdir -p ${TITLE}
cd ${TITLE}

##Wait function for output files:
wait_output() {
    local output="$1"; shift

    until [ -f $output ] 
    do echo "We are sleeping until $output is generated. 5 more minutes."; sleep 300
    done  
}


##Assembly download:
echo "\
sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=asm --output=%x_%A.out --wrap="wget --no-check-certificate ${URL}""
sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=asm --output=%x_%A.out --wrap="wget --no-check-certificate ${URL}"
echo "Assembly downloaded."


##Genomic data download:
mkdir -p ./genomic_data/10x ./genomic_data/pacbio_hifi ./genomic_data/illumina
echo "Downloading genomic data."

#10x:
echo "\
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_10x --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ./genomic_data/10x | awk '{print $4}' >> 10x.id"
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_10x --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ./genomic_data/10x | awk '{print $4}' >> 10x.id
#pacbio_hifi:
echo "\
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_pacbiohifi --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi | awk '{print \$4}' >> hifi.id"
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_pacbiohifi --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi | awk '{print $4}' >> hifi.id
#illumina:
echo "\
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_illumina --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ./genomic_data/illumina | awk '{print $4}' >> illumina.id"
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_illumina --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ./genomic_data/illumina | awk '{print $4}' >> illumina.id

cat 10x.id hifi.id illumina.id >> jobs.id

job_nums=`wc -l jobs.id | awk '{print $1}'`

if [[ $job_nums -eq 1 ]]
then
   jid=`cat jobs.id`
   WAIT=$WAIT$jid
else
    for jid in $(cat jobs.id)
    do
        WAIT=$WAIT$jid","
    done
    WAIT=${WAIT::-1}
fi
 echo $WAIT
##waiting until all aws download jobs are done to check for genomic data

echo "\
sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:$WAIT --job-name=reads_check --output=%x_%A.out --wrap=\"sh /lustre/fs5/vgl/store/cjohnson02/bin/Merqury_QV_slurm/dw_reads_check.sh\" | awk '{print $4}' > check.id"
sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:$WAIT --job-name=reads_check --output=%x_%A.out --wrap="sh /lustre/fs5/vgl/store/cjohnson02/bin/Merqury_QV_slurm/dw_reads_check.sh" | awk '{print $4}' > check.id


#kreeq:
echo "/
sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat check.id` --job-name=kreeq --output=%x_%A.out --wrap=\"sh /lustre/fs5/vgl/store/cjohnson02/bin/Merqury_QV_slurm/kreeq_run.sh\" | awk '{print $4}' > kreeq.id"
sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat check.id` --job-name=kreeq --output=%x_%A.out --wrap="sh /lustre/fs5/vgl/store/cjohnson02/bin/Merqury_QV_slurm/kreeq_run.sh" | awk '{print $4}' > kreeq.id

wait_output done.out



##Summary:
Species_summary_list () {
if test -n "$(find kreeq_QV_10x -maxdepth 0)"
then
  echo -n && cat kreeq_QV_10x >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   10x    ${TITLE}" >> ../Summary_QV.file
fi
if test -n "$(find kreeq_QV_pacbio_hifi -maxdepth 0)"
then
  echo -n && cat kreeq_QV_pacbio_hifi >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   Pacbio_hifi    ${TITLE}" >> ../Summary_QV.file
fi
if test -n "$(find kreeq_QV_illumina -maxdepth 0)"
then
  echo -n && cat kreeq_QV_illumina >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   Illumina    ${TITLE} " >> ../Summary_QV.file
fi
}

Species_summary_list
echo "Summary data loaded to table."