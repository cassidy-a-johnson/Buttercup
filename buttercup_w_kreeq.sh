#!/bin/bash

##BUTTERCUP

##This program is designed to download the assembly and genomic data of a species, then calculate the QV (Quality Value) score 
##      of the species assembly using Meryl and Merqury and organizes outputs.


#Importantly, the kreeq database can only be computed once on the read set, 
#and reused for multiple analyses to save runtime:
#kreeq validate -r testFiles/random1.fastq -o db.kreeq
#kreeq validate -f testFiles/random1.fasta -d db.kreeq

#Similarly, kreeq databases can be generated separately for
# multiple inputs and combined, with increased performance in HPC environments:
#kreeq validate -r testFiles/random1.fastq -o random1.kreeq
#kreeq validate -r testFiles/random2.fastq -o random2.kreeq

#time kreeq union -d random1.kreeq random2.kreeq -o union.kreeq
#time kreeq validate -f testFiles/random1.fasta -d union.kreeq

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

if test -n "$(find ./genomic_data/10x/ -empty)"
then
    echo "No 10x genomic data."
else
time kreeq validate -r ./genomic_data/10x/*.fastq* -o 10x.kreeq 
  ##needs to run kreeq on INDIVIDUAL READ SET; once ethis is done run union; then validate

time kreeq union -d 10x.kreeq -o union_10x.kreeq
time kreeq validate -f *fna.gz -d union_10x.kreeq
fi

#QUESTION: should I just make this a for loop?




##NOTE:NEED TO CHANGE "SUMMARY" SECTION TO MATCH NEW NAMING OF OUTPUT FILES

##Summary:
Species_summary_list () {
if test -n "$(find ${TITLE}_10x_Merqury.qv -maxdepth 0)"
then
  echo && cat ${TITLE}_10x_Merqury.qv >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   10x    ${TITLE}" >> ../Summary_QV.file
fi
if test -n "$(find ${TITLE}_hifi_Merqury.qv -maxdepth 0)"
then
  echo && cat ${TITLE}_hifi_Merqury.qv >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   Pacbio_hifi    ${TITLE}" >> ../Summary_QV.file
fi
if test -n "$(find ${ID}_illumina_Merqury.qv -maxdepth 0)"
then
  echo && cat ${TITLE}_illumina_Merqury.qv >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   Illumina    ${TITLE} " >> ../Summary_QV.file
fi
}

Species_summary_list
echo "Summary data loaded to table."

##NOTE:NEED TO CHANGE "SUMMARY" SECTION TO NEW DEPENDENCY
    ##PERHAPS A NEW DEPENDENCY ON THE SUMMARY GENERATION
##Cleaning
echo "Cleaning unnecessary files."
sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=rm_genomic_data --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="rm -dfrv ./genomic_data/"

sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=mv_meryl --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="mv *.meryl.hist ./meryl/; mv *.meryl.list ./meryl/"

sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=rm_meryl_etc --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="rm -dfrv ./meryl/; rm -frdv *.meryl; rm *.dat; rm *.fastq.gz; rm *fna.gz"
