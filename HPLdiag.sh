#!/bin/bash
postfix=`date +'%m%d%y'`
echo "Starting HPLmon diagnostics on Comet (`date`)" >> log/HPLresults.$postfix
echo "-----------------------------------------------------------" >> log/HPLresults.$postfix
spinq="/-\|"
while read line; do
	# Get node and partition from input file
	node=`echo $line | awk '{ print $1}'`
	partition=`echo $line | awk '{ print $2}'`
	# Dispatch job based on the partition
	if [ "$partition" == "compute" -o "$partition" == "shared" ]; then
		sbatch -w $node -p $partition hpl_1n_12p_2t.comet $postfix > /dev/null
	elif [ "$partition" == "gpu" -o "$partition" == "gpu-shared" ]; then
		echo "Skipping $node: $partition currently unsupported for testing." >> log/HPLresults.$postfix
	fi
	# Update spinner
	spinf=${spinq#?}
	printf "Dispatching jobs [%c] " "$spinq"
	spinq=$spinf${spinq%"$spinf"}
	printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
done < $1
# This part cancels all jobs with a reason code "ReqNodeNotAvail"
# I've commented this out because it appears jobs in this state
# aren't necessarily offline. Sometimes they're are actually just
# running another users job. Need to research this reason code more.
# An alternative might also be to find a better way to enumerate offline nodes
# My best guess would be sinfo
#squeue -o "%R %i %n" -u $USER | grep "ReqNodeNotAvail" | while read line; do 
#	DOAjobid=`echo $line | awk '{ print $2}'`
#	DOAnode=`echo $line | awk '{ print $3}'`
#	scancel $DOAjobid
#	echo "$DOAjobid $DOAnode UNAVAILABLE" >> log/HPLresults.$postfix
#done
