#!/bin/bash

##This program checks whether genomic data has been downloaded in any data type
##If no genomic data is present, the program ends

if test -n "$(find ./genomic_data/10x/ -maxdepth 0 -empty)" && test -n "$(find ./genomic_data/illumina/ -maxdepth 0 -empty)" && test -n "$(find ./genomic_data/pacbio_hifi/ -maxdepth 0 -empty)" 
then
    echo $?
    echo "No genomic data from GenomeArk! \
        Program ending for this species." >> fail.out
else
    echo "Raw reads downloaded."
fi

##3/22/23
if find fail.out -maxdepth 0
then
    echo "oops!!"
fi