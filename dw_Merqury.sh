#!/bin/bash

LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p < /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/genomes.ls[store]))
 
echo $LINE
NAME=${LINE[0]}
ID=${LINE[1]}
URL=${LINE[2]} 

mkdir -p ./Merqury_logs

##run qv.sh:

sbatch --partition=vgl --thread-spec=32 /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl *.fna.gz ${ID}_Merqury

##remove meryl:
sbatch --partition=vgl --thread-spec=32 --wrap="rm -dfrv ./meryl/; rm -dv G*.meryl"
