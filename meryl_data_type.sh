#!/bin/bash

##This is a script to run Meryl, differentiating between the genomic data types (illumina, hifi, 10x)


# Determining whether the genomic data directory has short reads or not (by type)
 if test -n "$(find ./genomic_data/10x/ -maxdepth 0 -empty)" ; then
    echo "No 10x genomic data."
else    
    echo "This species has 10x genomic data." > 10x
    cat 10x
    ls ./genomic_data/10x/*R*.fastq.gz > input.fofn
        echo "/
        sbatch --partition=vgl --wait $STORE/bin/Merqury_QV_slurm/_submit_meryl2_10x_cj.sh 21 summary vgl 32 | awk '{print $4}' >> transformer.id"
        sbatch --partition=vgl --wait $STORE/bin/Merqury_QV_slurm/_submit_meryl2_10x_cj.sh 21 summary vgl 32 | awk '{print $4}' >> transformer.id
fi

 if test -n "$(find ./genomic_data/pacbio_hifi/ -maxdepth 0  -empty)" ; then
    echo "No pacbio hifi data."
else  
    echo "This species has pacbio hifi genomic data." > Pacbio_hifi
    cat Pacbio_hifi
    ls ./genomic_data/pacbio_hifi/*.fastq.gz > R.fofn
    echo "/sbatch --partition=vgl --wait $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R.fofn summary vgl | awk '{print $4}' >> transformer.id"
        sbatch --partition=vgl --wait $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R.fofn summary vgl | awk '{print $4}' >> transformer.id
fi  

 if test -n "$(find ./genomic_data/illumina/ -maxdepth 0  -empty)" ; then
    echo "No iilumina genomic data."
else  
    echo "This species has illumina genomic data." > Illumina
    cat Illumina
    ls ./genomic_data/illumina/*.fastq.gz > R1_R2.fofn
    echo "sbatch --partition=vgl --wait $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R1_R2.fofn summary vgl | awk '{print $4}' >> transformer.id"
        sbatch --partition=vgl --wait $VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 R1_R2.fofn summary vgl | awk '{print $4}' >> transformer.id
fi