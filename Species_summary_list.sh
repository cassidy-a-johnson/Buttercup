#!/bin/bash

#Function: to create summary list of species and QV values among other features
TITLE=bTaeGut2.pat

Species_summary_list () {
if test -n "$(find kreeq*10x.out -maxdepth 0)"
then
  echo -n && cat kreeq*10x.out >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   10x    ${TITLE}" >> ../Summary_QV.file
fi
if test -n "$(find kreeq*pacbio_hifi.out -maxdepth 0)"
then
  echo -n && cat kreeq*pacbio_hifi.out >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   Pacbio_hifi    ${TITLE}" >> ../Summary_QV.file
fi
if test -n "$(find kreeq*illumina.out -maxdepth 0)"
then
  echo -n && cat kreeq*illumina.out >> ../Summary_QV.file
    truncate -s-1 ../Summary_QV.file
    echo -n "   Illumina    ${TITLE} " >> ../Summary_QV.file
fi
}

Species_summary_list
echo "Summary data loaded to table."