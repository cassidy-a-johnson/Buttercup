#!/bin/bash


#until 
#find ./Merq -maxdepth 0
#do sleep 10
#echo "sleeping for 10 sec"
#done
#echo $?

sbatch --partition=vgl --thread-spec=32 /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl *.fna.gz bAcrTri1_Merqury

#sbatch --partition=vgl --thread-spec=32 --output=${ID}/Merqury_logs/dw.%A_%a.out --error=${ID}/Merqury_logs/dw.%A_%a.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl *.fna.gz ${ID}_Merqury

#doesn't work with the output and error options



##Worked 2/2/23:
#sbatch --partition=vgl /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl GCA_016904835.1_bAcaChl1.pri_genomic.fna Merqury 

#sbatch --partition=vgl /lustre/fs4/vgl/store/vglshare/tools/VGP-tools/merqury/_submit_merqury.sh mem=F.meryl GCA_018492685.1_fAloSap1.pri_genomic.fna Merqury

##CAUTION: REMEMBER TO GENERALIZE POPULATED INPUT!!!
##add dependency

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


#<read.meryl> = summary.meryl

##<asm1.fasta> = .fna.gz
#need to populate the genome into the merqury sbatch
    # will *.fna.gz work?
    # or do i need to create some variable?

#<out> = Merqury