#!/bin/bash

LINE=($(sed -n  ${SLURM_ARRAY_TASK_ID}p ${1}))
 
echo $LINE
NAME=${LINE[0]}
ID=${LINE[1]}
URL=${LINE[2]} 

mkdir -p ./Merqury_logs

##run qv.sh:
echo "/
sbatch --partition=vgl --thread-spec=32 --dependency="afterok:$(cat meryl.id)" --output={$ID}/Merqury_logs/dw.%A_%a.out --error={$ID}/Merqury_logs/dw.%A_%a.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl *.fna.gz Merqury | awk '{print $4}' > merqury.jid"
sbatch --partition=vgl --thread-spec=32 --dependency="afterok:$(cat meryl.id)" --output={$ID}/Merqury_logs/dw.%A_%a.out --error={$ID}/Merqury_logs/dw.%A_%a.out /rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/qv.sh summary.meryl *.fna.gz Merqury | awk '{print $4}' > merqury.jid

##remove meryl:
#make sure rm -v
#wrapper to ensure QV has been generated before removing *.meryl files
    #Linelle: sbatch --parition=vgl --nodes=1 --cpus-per-task=32 --wrap="meryl whatever"
sbatch --partition=vgl --thread-spec=32 --dependency="afterok:$(cat merqury.jid)" --wrap=/rugpfs/fs0/vgl/store/cjohnson02/bin/Merqury_QV_slurm/rm_meryl.sh



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