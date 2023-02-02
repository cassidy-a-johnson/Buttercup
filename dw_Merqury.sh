#!/bin/bash

mkdir -p Merqury

#$tools/merqury/_submit_merqury.sh ${2}.meryl ${2}_10x_reads_R1.fastq.gz ${2}_10x_reads_R2.fastq.gz R1_R2_reads

#sbatch --partition=vgl /lustre/fs4/vgl/store/vglshare/tools/VGP-tools/merqury/_submit_merqury.sh mem=F.meryl GCA_018492685.1_fAloSap1.pri_genomic.fna Merqury

##run qv.sh
#path = /lustre/fs4/vgl/store/vglshare/tools/VGP-tools/merqury/eval/qv.sh

#"Usage: ./qv.sh <read.meryl> <asm1.fasta> [asm2.fasta] <out>"
        #echo
        #echo -e "\t<read.meryl>:\tk-mer db of the (illumina) read set"
        #echo -e "\t<asm1.fasta>:\t assembly 1"
        #echo -e "\t[asm2.fasta]:\t assembly 2, optional"
        #echo -e "\t<out>.qv:\tQV of asm1, asm2 and both (asm1+asm2)"
        #echo
        #echo "** This script calculates the QV only and exits. **"
        #echo "   Run spectra_cn.sh for full copy number analysis."



sbatch --partition=vgl /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl GCA_016904835.1_bAcaChl1.pri_genomic.fna Merqury 

#<read.meryl> = summary.meryl

##<asm1.fasta> = .fna.gz
#need to populate the genome into the merqury sbatch
    # will *.fna.gz work?
    # or do i need to create some variable?

#<out> = Merqury