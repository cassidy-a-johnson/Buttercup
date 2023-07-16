#!/bin/bash

#Function: to create summary list of species and QV values among other features
ID=mNeoNeb1

Species_summary_list () {
if test -n "$(find ${ID}_10x_Merqury.qv -maxdepth 0)"
then
  echo && cat ${ID}__10x_Merqury.qv >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   10x    ${ID}" >> ../Summary_QV.file
fi
if test -n "$(find ${ID}_pacbio_hifi_Merqury.qv -maxdepth 0)"
then
  echo && cat ${ID}_pacbio_hifi_Merqury.qv >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   Pacbio_hifi    ${ID}" >> ../Summary_QV.file
fi
if test -n "$(find ${ID}_illumina_Merqury.qv -maxdepth 0)"
then
  echo && cat ${ID}_illumina_Merqury.qv >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   Illumina    ${ID} " >> ../Summary_QV.file
fi
}

Species_summary_list
echo "Summary data loaded to table."