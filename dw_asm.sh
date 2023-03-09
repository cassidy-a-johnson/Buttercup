#!/bin/bash

##This script downloads the assmeblies of species in the input file by URL (FTP)

LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
echo $LINE
NAME=${LINE[0]}
ID=${LINE[1]}
URL=${LINE[2]}

mkdir -p ${ID}
cd ${ID}

##upload the assemblies:
wget --no-check-certificate ${URL}