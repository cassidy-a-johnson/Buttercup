#!/bin/bash

#This is a script where I work on extracting the Species ID from the assembly fasta file for the Summary QV list.

#fasta title:
GCA_947179515.1_mApoSyl1.1_genomic
#I want:
mApoSyl1.1
    #I only want stuff after and before the _

#printing the first word:
cat bAcrTri1_Merqury.qv | head -n1 | awk '{print $1;}'

#cutting around the "_":
echo 'someletters_12345_moreleters.ext' | cut -d'_' -f 2
    output=12345

#trying to combine them:
cat bAcrTri1_Merqury.qv | head -n1 | awk '{print $1;}'| cut -d'_' -f 3 | cut -d '.' -f 1
    #-d tells it what to cut out
    #-f tells it which component of the string after the cut[split] to print