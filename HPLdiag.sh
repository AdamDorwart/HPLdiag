#!/bin/bash
time=`date +'%m%d%y'`
while read line; do
	node=`echo $line | awk '{ print $3}'`
	sbatch -w $node hpl_1n_12p_2t.comet $time
done < $1
