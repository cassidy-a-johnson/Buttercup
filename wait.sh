#!/bin/bash


echo -n "first " >> check.id
echo -n "second " >> check.id
echo -n "third " >> check.id

cat check.id | head -n1 | awk '{print $1;}'
cat check.id | head -n1 | awk '{print $2;}'
TRY=($(cat check.id | head -n1 | awk '{print $3;}'))


echo "ya"
sleep 1 &
pid=$!
wait 
#wait $pid
echo $!

#wait

echo $TRY
echo $TRY
#cat aws.jid | head -n1 | awk '{print $1;}'


#wait_output() {
  #local output="$1"; shift

  #until [ -d $output ] ; do sleep 300; done
  
#}
#wait_output ./summary.meryl