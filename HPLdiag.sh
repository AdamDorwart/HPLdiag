#!/bin/bash
postfix=`date +'%m%d%y'`
echo "Starting HPLmon diagnostics on Comet (`date`)" >> log/HPLresults.$postfix
echo "-----------------------------------------------------------" >> log/HPLresults.$postfix
while read line; do
	node=`echo $line | awk '{ print $3}'`
	sbatch -w $node hpl_1n_12p_2t.comet $postfix
done < $1
squeue -o "%R %i %n" -u adorwart | grep "ReqNodeNotAvail" | while read line; do 
	DOAjobid=`echo $line | awk '{ print $2}'`
	DOAnode=`echo $line | awk '{ print $3}'`
	scancel $DOAjobid
	echo "$DOAjobid $DOAnode UNAVAILABLE" >> log/HPLresults.$postfix
done

