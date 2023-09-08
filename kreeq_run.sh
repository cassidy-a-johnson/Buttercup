#!/bin/bash

#Here is where the kreeq program runs


for DATATYPE in 10x pacbio_hifi illumina
do

  if
    test -n $(find ./genomic_data/${DATATYPE}/* -maxdepth 0)
  then
  echo "No ${DATATYPE} data."
  continue
  else
    cd ./genomic_data/${DATATYPE}/ 
    num_reads=`ls -1 | wc -l`
    echo $num_reads
fi

for FILE in *
    do
      echo $FILE
      echo "\
      time srun -pvgl --job-name=${FILE}_db_stats --output=%x_%A.out kreeq validate -r $FILE -o ${FILE}_db.kreeq"
      time srun -pvgl --job-name=${FILE}_db_stats --output=%x_%A.out kreeq validate -r $FILE -o ${FILE}_db.kreeq

    done

echo "\
time srun -pvgl --job-name=union_dbs --output=%x_%A.out kreeq union -d *.kreeq -o union_${DATATYPE}.kreeq"
time srun -pvgl --job-name=union_dbs --output=%x_%A.out kreeq union -d *.kreeq -o union_${DATATYPE}.kreeq
echo "\
time srun -pvgl --job-name=${TITLE}_${DATATYPE}_QV --output=%x_%A_QV_${DATATYPE}.out kreeq validate -f ../../*.fna.gz -d union_${DATATYPE}.kreeq"
time srun -pvgl --job-name=${TITLE}_${DATATYPE}_QV --output=%x_%A_QV_${DATATYPE}.out kreeq validate -f ../../*.fna.gz -d union_${DATATYPE}.kreeq 


mv kreeq*.out ../../
cd ../../

done

echo "Kreeq is done running" >> done.out