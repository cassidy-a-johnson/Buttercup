#!/bin/bash

echo "Trim barcodes off from 10X reads and build meryl dbs"
if [[ -z $1 ]] || [[ -z $2 ]]; then
    echo "Usage: ./_submit_meryl2_10x.sh <k-size> <out_prefix> <partition> <cpus> [extra]"
    echo -e "\t<k-size>: kmer size k"
    echo -e "\t<out_prefix>: Final merged meryl db will be named as <out_prefix>.meryl"
    exit -1
fi

# meryl_count=/path/to/meryl/scripts/meryl_count
meryl_count=$VGP_PIPELINE/meryl2/meryl_count

ls ./genomic_data/10x/*_R1_001.fastq.gz > input.fofn
LINES=`wc -l input.fofn | awk '{print $1}'`

for i in $(seq 1 $LINES)
do
    q1=`sed -n ${i}p input.fofn`
    q2=${q1/_R1_/_R2_}
    echo "Generate input$i.dat: $q1 $q2"
    echo "q1=$PWD/$q1" > input$i.dat
    echo "q2=$PWD/$q2" >> input$i.dat
done

out_prefix=$2

partition=$3

cpus=24
name=trim_$out_prefix
script=$meryl_count/trim_bc.sh
args=""
walltime=1-0
path=`pwd`
extra="--array=1-$LINES"
log=logs/$name.%A_%a.log

mkdir -p logs

echo "\
sbatch -J $name --partition=$partition --cpus-per-task=$cpus -D $path $extra --time=$walltime --error=$log --output=$log $script $args"
sbatch -J $name --partition=$partition --cpus-per-task=$cpus -D $path $extra --time=$walltime --error=$log --output=$log $script $args > trim.jid

k=$1
input_fofn=trimmed.fofn

if ! [ -s $input_fofn ]; then
    for i in $(seq 1 $LINES)
    do
        echo "read_$i-BC1.fastq.gz" >> $input_fofn
        echo "read_$i-BC2.fastq.gz" >> $input_fofn
    done
fi

#extra="--dependency=afterok:"`cat trim.jid`
extra="--dependency=afterok:"`cat trim.jid | tail -n 1 | cut -d' ' -f4`
echo $extra

LEN=`wc -l $input_fofn | awk '{print $1}'`
offset=$((LEN/1000))
leftovers=$((LEN%1000))

mkdir -p logs

cpus=$4 # Max: 64 per each .meryl/ file writer
name=meryl_count.$out_prefix
script=$meryl_count/meryl2_count.sh
walltime=1-0
path=`pwd`
log=logs/$name.%A_%a.log

if [ -e meryl_count.jid ]; then
    echo "Removing meryl_count.jid"
    cat meryl_count.jid
    rm meryl_count.jid
fi

for i in $(seq 0 $offset)
do
    args="$k $input_fofn $i"
    if [[ $i -eq $offset ]]; then
        arr_max=$leftovers
    else
        arr_max=1000
    fi
    echo "\
    sbatch -J $name --partition=$partition --cpus-per-task=$cpus -D $path $extra --array=1-$arr_max --time=$walltime --error=$log --output=$log $script $args"
    sbatch -J $name --partition=$partition --cpus-per-task=$cpus -D $path $extra --array=1-$arr_max --time=$walltime --error=$log --output=$log $script $args >> meryl_count.jid
done

# Wait for these jobs
WAIT="afterok:"

job_nums=`wc -l meryl_count.jid | awk '{print $1}'`

if [[ $job_nums -eq 1 ]]; then
   #jid=`cat meryl_count.jid`
   jid=`cat meryl_count.jid | tail -n 1 | cut -d' ' -f4`
   WAIT=$WAIT$jid
else
    for jid in $(cat meryl_count.jid)
    do
        WAIT=$WAIT$jid","
    done
fi

## Collect .meryl list
if [ -e  meryl_count.meryl.list ]; then
    echo "Removing meryl_count.meryl.list"
    cat meryl_count.meryl.list
    rm  meryl_count.meryl.list
fi

for line_num in $(seq 1 $LEN)
do
    input=`sed -n ${line_num}p $input_fofn`
    name=`echo $input | sed 's/.fastq.gz$//g' | sed 's/.fq.gz$//g' | sed 's/.fasta$//g' | sed 's/.fa$//g' | sed 's/.fasta.gz$//g' | sed 's/.fa.gz$//g'`
    name=`basename $name`
    echo "$name.$k.$line_num.meryl" >> meryl_count.meryl.list
done

cpus=$4 # Max: 64 per each .meryl/ file writer
name=meryl_union_sum
log=logs/$name.%A_%a.log
script=$meryl_count/meryl2_union_sum.sh
args="$k meryl_count.meryl.list $out_prefix"
echo "\
sbatch -J $name --partition=$partition --cpus-per-task=$cpus -D $path --dependency=$WAIT --time=$walltime --error=$log --output=$log $script $args"
sbatch -J $name --partition=$partition --cpus-per-task=$cpus -D $path --dependency=$WAIT --time=$walltime --error=$log --output=$log $script $args > meryl_union_sum.jid

WAIT="afterok:"`cat meryl_union_sum.jid | tail -n 1 | cut -d' ' -f4`

cpus=$4 # Max: 64 per each .meryl/ file writer
name=genomescope
log=logs/$name.%A_%a.log
script=$VGP_PIPELINE/meryl2/genomescope.sh
args="$k $out_prefix"
echo "\
sbatch -J $name --partition=$partition --cpus-per-task=$cpus -D $path --dependency=$WAIT --time=$walltime --error=$log --output=$log $script $args"
sbatch -J $name --partition=$partition --cpus-per-task=$cpus -D $path --dependency=$WAIT --time=$walltime --error=$log --output=$log $script $args