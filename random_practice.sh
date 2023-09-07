#!/bin/bash

#generating the data type signal/file
#echo "This species has 10x genomic data" > 10x
#cat 10x

#echo "This species has illumina genomic data" > Illumina
#cat Illumina

#echo "This species has pacbio hifi genomic data" > Pacbio_hifi
#cat Pacbio_hifi


#checking if the file is there
#if [ "$(ls -A 10x)" ]; then
    #echo -n "10x"
#elif [ "$(ls -A Illumina)" ]; then
    #echo -n "Illumina"
#else [ "$(ls -A Pacbio_hifi)" ]; then
    #echo -n "Pacbio Hifi"
#fi

##QUESTION: would it be worth it to add the species NAME and ID to the list first?




##CHECKING IF THE READS ARE ACTUALLY THERE

if test -n "$(find ./genomic_data/pacbio_hifi/ -maxdepth 0 -empty)" ; then
    echo "No pacbio hifi data"
else    
    echo "${ID} has pacbio hifi data" > Pacbio_hifi
    cat Pacbio_hifi
fi

if test -n "$(find ./genomic_data/illumina/ -maxdepth 0 -empty)" ; then
    echo "No illumina data"
else    
    echo "${ID} has illumina data" > Illumina
    cat Illumina
fi

if test -n "$(find ./genomic_data/10x/ -maxdepth 0 -empty)" ; then
    echo "No 10x data"
else    
    echo "${ID} has 10x data" > 10x
    cat 10x
fi


##THIS ONE WORKS!!
 if test -n "$(find ./genomic_data/pacbio_hifi/ -maxdepth 0 -empty)" ; then
    echo "No pacbio hifi data"
else    
    echo "${ID} has pacbio hifi genomic data" > Pacbio_hifi
    cat Pacbio_hifi
    ls ./genomic_data/pacbio_hifi/*.fastq.gz > R.fofn
        sbatch --partition=vgl $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R.fofn summary vgl | awk '{print $4}' > meryl.id
fi


##test this one next:
if [ -n "$(ls -A ./genomic_data/pacbio_hifi)" ]; then
    #readlink -f /${ID}/genomic_data/pacbio_hifi > ${ID}_abs_path.ls
    echo "${ID} has pacbio hifi genomic data" > Pacbio_hifi
    cat Pacbio_hificat
    ls ./genomic_data/pacbio_hifi/*.fastq.gz > R.fofn
        sbatch --partition=vgl --dependency="afterok:$(cat job.id)" $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R.fofn ${ID}_summary vgl | awk '{print $4}' > meryl.id
fi

##check for download of genomic data
    ##FURTHER EDITED IN DW_READS_CHECK.SH
if test -n "$(find ./genomic_data/10x -maxdepth 0 -empty)" && "$(find ./genomic_data/illumina -maxdepth 0 -empty)" \
&& "$(find ./genomic_data/pacbio_hifi -maxdepth 0 -empty)"; then
    echo $?
    echo "No genomic data from GenomeArk! \
        Program ending with ${ID}."
    exit
fi

job_id=$(sbatch --parsable test.sh)
echo $job_id


#to print jjust the ID, QV, and data type:
awk '{print $7 " " $4 " "  $6}' Summary_QV.file

#3/22/23
#To automatically truncate the data: IHSGRIOHDRGJNLGS
    #Extracting values in columns 4[QV], 5[Error rate], 6[Data type], and 7[Species ID]
    awk '{ print $7, $6, $4, $5 }' ../Summary_QV.file >> ../Truncated_Summary_QV.file
    #This doesn't work! It recapitulated the ENTIRE list everytime!
##there's been a suggestsion to include the error rate too which would be column 5

#will do one big truncation at the end!


##3/26/23

#to find all fail.out files from $SCRATCH
    #find ./*/fail.out -maxdepth 2
    

#to isolate the "pat" or "mat"
prinf GCA_902713425.2_fAciRut3.2_maternal_haplotype_genomic.fna.gz | cut -d'_' -f 4
    #gives you "maternal"
printf GCA_011100555.2_mCalJa1.2.pat.X_genomic.fna.gz | cut -d '.' -f 4
                ###NOTE:SOMEONE PUT A TYPO [MCALJA1] WHEN ENTERING THE ASM!!!

##USE THIS TO EXTRACT WORKING SPECIES ID FROM SPECIES "TITLE"
TITLE=GCA_011100555.2_mCalJa1.2.pat.X_genomic.fna.gz
printf $TITLE | cut -d'_' -f 3 | cut -d '.' -f 1
    #mCalJa1
ID=($(printf $TITLE | cut -d'_' -f 3 | cut -d '.' -f 1))
    #mCalJa1

[cjohnson02@login04 fAciRut3]$ TITLE=fAciRut3.2_paternal
[cjohnson02@login04 fAciRut3]$ printf $TITLE | cut -d'_' -f 3 | cut -d '.' -f 1

[cjohnson02@login04 fAciRut3]$ printf $TITLE | cut -d'_' -f 1 | cut -d '.' -f 1
fAciRut3

[cjohnson02@login04 fAciRut3]$ TITLE=mCalJa1.2.pat
[cjohnson02@login04 fAciRut3]$ printf $TITLE | cut -d'_' -f 1 | cut -d '.' -f 1
mCalJa1

#https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/902/713/435/GCA_902713435.2_fAciRut3.2_paternal_haplotype/GCA_902713435.2_fAciRut3.2_paternal_haplotype_genomic.fna.gz
https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/011/100/555/GCA_011100555.2_mCalJa1.2.pat.X/GCA_011100555.2_mCalJa1.2.pat.X_genomic.fna.gz


NAME=${LINE[0]}
TITLE=${LINE[1]}
URL=${LINE[2]}

#Correct $TITLE format:
    #TITLE=mfAciRut3.pat

Callithrix_jacchus	mCalJac1.pat    DO MANUALLY[TYPO]	https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/011/100/555/GCA_011100555.2_mCalJa1.2.pat.X/GCA_011100555.2_mCalJa1.2.pat.X_genomic.fna.gz



##4/19/23: Differentiating different data types for meryl runs and then Merqury

