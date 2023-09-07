#!/bin/bash
TITLE=bTaeGut2

wait_output() {
    local output="$1"; shift

    until [ -d $output ] 
    do echo "We are sleeping until the summary file is generated. 5 more minutes."; sleep 300
    done  
}


for DATATYPE in 10x pacbio_hifi illumina
do
MERYL=${DATATYPE}_meryl.jid
SUMMARY=summary_${DATATYPE}.meryl
MERQURY=Merqury_${DATATYPE}.jid
OUTPUT=${TITLE}_${DATATYPE}_Merqury
DATA=genomic_data/${DATATYPE}/

echo "\
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat ${MERYL}` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh ${SUMMARY} *.fna.gz ${OUTPUT} | awk '{print $4}' >> ${MERQURY}"
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat ${MERYL}` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh ${SUMMARY} *.fna.gz ${OUTPUT} | awk '{print $4}' >> ${MERQURY}
    wait_output ${OUTPUT}
    echo "${OUTPUT} has been generated."
cat Merqury_10x.jid Merqury_pacbio_hifi.jid Merqury_illumina.jid >> Merqury.jid
done