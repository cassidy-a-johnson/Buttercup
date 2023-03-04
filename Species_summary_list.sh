#!/bin/bash

#Function: to create summary list of species and QV values among other features

Species_summary_list () {
    echo && cat *Merqury.qv >> ../Summary_QV.file
if find 10x -maxdepth 0; then
    truncate -s-1 ../Summary_QV.file
    echo -n "   10x " >> ../Summary_QV.file
    cat *Merqury.qv | head -n1 | awk '{print $1;}'| cut -d'_' -f 3 | cut -d '.' -f 1 >> ../Summary_QV.file
else echo "Not a 10x species."
fi
if find ./Illumina -empty; then
    truncate -s-1 ../Summary_QV.file
    echo -n "   Illumina " >> ../Summary_QV.file
    cat *Merqury.qv | head -n1 | awk '{print $1;}'| cut -d'_' -f 3 | cut -d '.' -f 1 >> ../Summary_QV.file
else echo "Not an Illumina species."
fi
if find ./Pacbio_hifi -maxdepth 0; then
    truncate -s-1 ../Summary_QV.file
    echo -n "   Pacbio_hifi " >> ../Summary_QV.file
    cat *Merqury.qv | head -n1 | awk '{print $1;}'| cut -d'_' -f 3 | cut -d '.' -f 1 >> ../Summary_QV.file
else echo "Not a Pacbio hifi species."
fi
}

Species_summary_list
