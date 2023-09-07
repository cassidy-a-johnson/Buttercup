#!/bin/bash

LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
##creating variables for each tab of the input table to be used throughout the program

NAME=${LINE[0]}
#ID=${LINE[1]}
TITLE=${LINE[1]}
ID=($(printf $TITLE | cut -d'_' -f 3 | cut -d'.' -f 1))
URL=${LINE[2]}
echo $NAME
echo $TITLE
echo $ID
echo $URL
