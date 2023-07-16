#!/bin/bash

##This program runs Meryl, differentiating between the genomic data types Illumina, Pacbio Hifi, and 10x)

##Determining whether the genomic data directory has reads or not (by type)
#10x
 if test -n "$(find ./genomic_data/10x/ -empty)"
then
    echo "No 10x genomic data."
else    
    echo "This species has 10x genomic data." > 10x
    cat 10x
    ls ./genomic_data/10x/*R*.fastq.gz >> input.fofn
        echo "/
        sbatch --partition=vgl --exclude=node[141-165] --nice $STORE/bin/Merqury_QV_slurm/_submit_meryl2_10x_cj.sh 21 summary_10x vgl 32 | awk '{print $4}' >> 10x_meryl.jid"
        sbatch --partition=vgl --exclude=node[141-165] --nice $STORE/bin/Merqury_QV_slurm/_submit_meryl2_10x_cj.sh 21 summary_10x vgl 32 | awk '{print $4}' >> 10x_meryl.jid
fi

#Pacbio Hifi
 if test -n "$(find ./genomic_data/pacbio_hifi/ -maxdepth 0  -empty)" 
 then
    echo "No pacbio hifi data."
else  
    echo "This species has pacbio hifi genomic data." > pacbio_hifi
    cat pacbio_hifi
    ls ./genomic_data/pacbio_hifi/*.fastq* >> R.fofn
    echo "/sbatch --partition=vgl --exclude=node[141-165]  --nice /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/_submit_meryl2_build_fastq.sh 21 R.fofn summary_pacbio_hifi vgl | awk '{print $4}' >> pacbio_hifi_meryl.jid"
           sbatch --partition=vgl --exclude=node[141-165]  --nice /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/_submit_meryl2_build_fastq.sh 21 R.fofn summary_pacbio_hifi vgl | awk '{print $4}' >> pacbio_hifi_meryl.jid 
fi  

#Illumina
 if test -n "$(find ./genomic_data/illumina/ -maxdepth 0  -empty)" 
 then
    echo "No iilumina genomic data."
else  
    echo "This species has illumina genomic data." > illumina
    cat illumina
    ls ./genomic_data/illumina/*.fastq.gz >> R1_R2.fofn
    echo "sbatch --partition=vgl --exclude=node[141-165] --nice $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R1_R2.fofn summary_illumina vgl | awk '{print $4}' >> illumina_meryl.jid"
          sbatch --partition=vgl --exclude=node[141-165] --nice $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R1_R2.fofn summary_illumina vgl | awk '{print $4}' >> illumina_meryl.jid
fi