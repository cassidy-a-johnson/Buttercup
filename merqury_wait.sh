#!/bin/bash

##This is a doucment to test out the wait function for merqury reliant on the summary output from meryl


SUMMARY=('summary_10x.meryl' 'summary_hifi.meryl' 'summary_illumina.meryl')

wait_output() {
  local output="$1"; shift

  until [ -d $output ] ; do sleep 300
  done
  
}
wait_output ${SUMMARY}

for DATATYPE in 10x hifi illumina
do
  SUMMARY=summary_${DATATYPE}.meryl
  OUTPUT=${ID}_${DATATYPE}_Merqury
  JID=Merqury_${DATATYPE}.jid
  DATA=/genomic_data/${DATATYPE}/
  #if
   echo test -n "${DATA} -maxdepth 0 -empty)"
  #then
    #continue
  #else
    echo "/
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat meryl.list` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh ${SUMMARY} *.fna.gz ${ID}_${OUTPUT} | awk '{print $4}' >> ${JID}"
    sbatch --partition=vgl --nice --exclude=node[141-165] --dependency=afterok:`cat meryl.list` --thread-spec=18 --job-name=Merqury --output=%x_%A.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh ${SUMMARY} *.fna.gz ${ID}_${OUTPUT} | awk '{print $4}' >> ${JID}
  #fi
done