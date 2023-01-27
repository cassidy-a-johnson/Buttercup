#!/bin/bash

LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
echo $LINE
NAME=${LINE[0]}
ID=${LINE[1]}
URL=${LINE[2]}

mkdir -p ${ID}
cd ${ID}

##upload the assemblies:
##wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/929/443/795/GCF_929443795.1_bAccGen1.1/GCF_929443795.1_bAccGen1.1_genomic.fna.gz

wget --no-check-certificate ${URL} 

##NOTE:
    ##change to wget ${URL} correct?
gunzip *.fna.gz
 