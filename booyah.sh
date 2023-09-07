#!/bin/bash

##FOR MERQURY AND BEYOND

LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))

TITLE=${LINE[0]}
echo $TITLE

cd ${TITLE}

wait_output() {
    local output="$1"; shift

    until [ -d $output ] 
    do echo "We are sleeping until the summary file is generated. 5 more minutes."; sleep 300
    done  
}

##Meryl:
mkdir -p meryl

for DATATYPE in 10x pacbio_hifi illumina
do
MERYL=${DATATYPE}_meryl.jid
SUMMARY=summary_${DATATYPE}.meryl
  if 
    find fail.out
    test -n "$(find ${DATATYPE} -maxdepth 0)" 
  then
    wait_output ${SUMMARY}
    echo "${MERYL} and ${SUMMARY} have been generated."
  else
    echo "${DATATYPE} is not present."
  fi
done

if
  find fail.out -maxdepth 0
then
  exit
else
test -n "$(find fail.out -maxdepth 0)" && echo "found" || echo "not found"


#Merqury:
cat 10x_meryl.jid pacbio_hifi_meryl.jid illumina_meryl.jid >> meryl_jid.list

for DATATYPE in 10x pacbio_hifi illumina
do
  SUMMARY=summary_${DATATYPE}.meryl
  OUTPUT=${TITLE}_${DATATYPE}_Merqury
  JID=Merqury_${DATATYPE}.jid
  DATA=genomic_data/${DATATYPE}/
  if
   test -n "$(find ${DATATYPE} -maxdepth 0)"
  then
    echo "\
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat meryl_jid.list` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh ${SUMMARY} *.fna.gz ${OUTPUT} | awk '{print $4}' >> ${JID}"
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat meryl_jid.list` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh ${SUMMARY} *.fna.gz ${OUTPUT} | awk '{print $4}' >> ${JID}
    echo "Merqury is running."
    wait_output ${OUTPUT}
  fi
done

cat Merqury_10x.jid Merqury_pacbio_hifi.jid Merqury_illumina.jid >> Merqury.jid


##Cleaning
echo "Cleaning unnecessary files."
sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=rm_genomic_data --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="rm -dfrv ./genomic_data/"

sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=mv_meryl --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="mv *.meryl.hist ./meryl/; mv *.meryl.list ./meryl/"

sbatch --partition=vgl --nice --exclude=node[141-165] --job-name=rm_meryl_etc --output=%x_%A.out --dependency="afterok:$(cat Merqury.jid)" --wrap="rm -frdv *.meryl; rm *.dat; rm *.fastq.gz; rm *fna.gz"


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