#!/bin/bash

if test -n "$(find ./genomic_data/10x/ -maxdepth 0 -empty)" && test -n "$(find ./genomic_data/illumina/ -maxdepth 0 -empty)" && test -n "$(find ./genomic_data/pacbio_hifi/ -maxdepth 0 -empty)"; then
    echo $?
    echo "No genomic data from GenomeArk! \
        Program ending for this species."
    exit
else
    echo "Raw reads downloaded."
fi

