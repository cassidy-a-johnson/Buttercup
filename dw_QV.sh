#!/bin/bash

##BUTTERCUP

##This program is designed to download the assembly and genomic data of a species, then calculate the QV (Quality Value) score 
##      of the species assembly using Meryl and Merqury and organizes outputs.



LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
##creating variables for each tab of the input table to be used throughout the program
echo $NAME
echo $ID
NAME=${LINE[0]}
#ID=${LINE[1]}
echo $TITLE
TITLE=${LINE[1]}
ID=($(printf $TITLE | cut -d'_' -f 3 | cut -d'.' -f 1))
URL=${LINE[2]}
#PARTITION=${LINE[3]}
#echo $PARTITION

#mkdir -p ${ID}
#cd ${ID}

##if there are paternal and maternal haplotypes, I recommend using titles such as bGalGal1.pat to keep track of species samples
mkdir -p ${TITLE}
cd ${TITLE}

##Assembly download:
echo "/
sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=asm --output=%x_%A.out --wrap="wget --no-check-certificate ${URL}""
sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=asm --output=%x_%A.out --wrap="wget --no-check-certificate ${URL}"
echo "Assembly downloaded."


##Genomic data download:
mkdir -p ./genomic_data/10x ./genomic_data/pacbio_hifi ./genomic_data/illumina
echo "Downloading genomic data."

#10x:
echo "/
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_10x --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ./genomic_data/10x | awk '{print $4}' >> 10x.id"
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_10x --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1*.fastq.gz" --include "*R2*.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/10x/ ./genomic_data/10x | awk '{print $4}' >> 10x.id
#pacbio_hifi:
echo "/
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_pacbiohifi --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" --include "*.fastq" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi | awk '{print $4}' >> hifi.id"
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_pacbiohifi --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*.fastq.gz" --include "*.fastq" s3://genomeark/species/${NAME}/${ID}/genomic_data/pacbio_hifi/ ./genomic_data/pacbio_hifi | awk '{print $4}' >> hifi.id
#illumina:
echo "/
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_illumina --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1.fastq.gz" --include "*R2.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ./genomic_data/illumina | awk '{print $4}' >> illumina.id"
sbatch --partition=vgl --nice --exclude=node[141-165] --thread-spec=8 --job-name=aws_illumina --output=%x_%A.out aws s3 cp --no-sign-request --recursive --exclude '*' --include "*R1.fastq.gz" --include "*R2.fastq.gz" s3://genomeark/species/${NAME}/${ID}/genomic_data/illumina/ ./genomic_data/illumina | awk '{print $4}' >> illumina.id

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

##waiting until all aws download jobs are done to check for genomic data

echo "/
sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:$WAIT --job-name=reads_check --output=%x_%A.out --wrap=\"sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/dw_reads_check.sh\" | awk '{print $4}' > check.id"
sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:$WAIT --job-name=reads_check --output=%x_%A.out --wrap="sh /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/dw_reads_check.sh" | awk '{print $4}' > check.id


##Meryl:
mkdir -p meryl
echo "Running Meryl."
echo "/
sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat check.id` --thread-spec=1 --job-name=Meryl --output=%x_%A.out $STORE/bin/Merqury_QV_slurm/meryl_data_type.sh"
sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat check.id` --thread-spec=1 --job-name=Meryl --output=%x_%A.out $STORE/bin/Merqury_QV_slurm/meryl_data_type.sh

for DATATYPE in 10x hifi illumina
do
MERYL=${DATATYPE}_meryl.jid
SUMMARY=summary_${DATATYPE}.meryl
  if 
    test -n "$(find ${MERYL} -maxdepth 0)" 
  then
    
    wait_output() {
    local output="$1"; shift

    until [ -d $output ] 
    do sleep 300
    done
}
    wait_output ${SUMMARY}
    echo "${MERYL} has been generated."
  else
    echo "${DATATYPE} is not present."
  fi
done


#Merqury:
echo "Running Merqury."

cat 10x_meryl.jid hifi_meryl.jid illumina_meryl.jid >> meryl_jid.list

for DATATYPE in 10x hifi illumina
do
  SUMMARY=summary_${DATATYPE}.meryl
  OUTPUT=${ID}_${DATATYPE}_Merqury
  JID=Merqury_${DATATYPE}.jid
  DATA=/genomic_data/${DATATYPE}/
  if
   echo test -n "${DATA} -maxdepth 0 -empty)"
  then
    continue
  else
    echo "/
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat meryl.list` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh ${SUMMARY} *.fna.gz ${OUTPUT} | awk '{print $4}' >> ${JID}"
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat meryl.list` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh ${SUMMARY} *.fna.gz ${OUTPUT} | awk '{print $4}' >> ${JID}
  fi
done

cat Merqury_10x.jid Merqury_hifi.jid Merqury_illumina.jid >> Merqury.jid


##Cleaning
echo "Cleaning unnecessary files."
sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=rm_genomic_data --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="rm -dfrv ./genomic_data/"

sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=mv_meryl --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="mv *.meryl.hist ./meryl/; mv *.meryl.list ./meryl/"

sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=rm_meryl_etc --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="rm -dfrv ./meryl/; rm -frdv *.meryl; rm *.dat; rm *.fastq.gz; rm *fna.gz"


##Summary:
Species_summary_list () {
if test -n "$(find ${ID}_10x_Merqury.qv -maxdepth 0)"
then
  echo && cat ${ID}_10x_Merqury.qv >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   10x    ${ID}" >> ../Summary_QV.file
fi
if test -n "$(find ${ID}_hifi_Merqury.qv -maxdepth 0)"
then
  echo && cat ${ID}_hifi_Merqury.qv >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   Pacbio_hifi    ${ID}" >> ../Summary_QV.file
fi
if test -n "$(find ${ID}_illumina_Merqury.qv -maxdepth 0)"
then
  echo && cat ${ID}_illumina_Merqury.qv >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   Illumina    ${ID} " >> ../Summary_QV.file
fi
}

Species_summary_list
echo "Summary data loaded to table."