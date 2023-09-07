for DATATYPE in 10x pacbio_hifi illumina
do

MERYL=${DATATYPE}_meryl.jid
SUMMARY=summary_${DATATYPE}.meryl
MERQURY=Merqury_${DATATYPE}.jid
OUTPUT=${TITLE}_${DATATYPE}_Merqury
DATA=genomic_data/${DATATYPE}/

mkdir -p meryl
  echo "\
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat check.id` --thread-spec=1 --job-name=Meryl --output=%x_%A.out $STORE/bin/Merqury_QV_slurm/meryl_data_type.sh"
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat check.id` --thread-spec=1 --job-name=Meryl --output=%x_%A.out $STORE/bin/Merqury_QV_slurm/meryl_data_type.sh

if
  test -n "$(find ./genomic_data/${DATATYPE}/ -empty)"
then
continue
else
  wait_output ${SUMMARY}
    echo "${MERYL} and ${SUMMARY} have been generated."
cat 10x_meryl.jid pacbio_hifi_meryl.jid illumina_meryl.jid >> meryl_jid.list

  echo "\
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat ${MERYL}` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh ${SUMMARY} *.fna.gz ${OUTPUT} | awk '{print $4}' >> ${MERQURY}"
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat ${MERYL}` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh ${SUMMARY} *.fna.gz ${OUTPUT} | awk '{print $4}' >> ${MERQURY}
    echo "Now running Merqury."
    wait_output ${OUTPUT}
    echo "${OUTPUT} has been generated."
cat Merqury_10x.jid Merqury_pacbio_hifi.jid Merqury_illumina.jid >> Merqury.jid
fi
done