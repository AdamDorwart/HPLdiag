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
	# Default to compute partition if none given
	if [ "$partition" == "compute" -o "$partition" == "shared" ]; then
		sbatch -w $node -p $partition hpl_1n_12p_2t.comet $postfix > /dev/null
	elif [ "$partition" == "gpu" -o "$partition" == "gpu-shared" ]; then
		sbatch -w $node -p $partition hpl_1n_12p_2t.comet $postfix > /dev/null
		# Need AMBER GPU tests as well as CPU/GPU HPL tests
	elif [ "$partition" == "" ]; then
		sbatch -w $node -p "compute" hpl_1n_12p_2t.comet $postfix > /dev/null
	fi
	# Update spinner
	spinf=${spinq#?}
	printf "Dispatching jobs [%c] " "$spinq"
	spinq=$spinf${spinq%"$spinf"}
	printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
done < $1
# Cancel all jobs for nodes that are down, failed, or in maintenece
sinfo -o "%n %T %E" | grep -e "maint" -e "down" -e "drained" -e "fail" | while read line; do
	DOAnode=`echo $line | awk '{print $1}'`
	DOAjobid=`squeue -o "%i %n" -u $USER | grep $DOAnode | awk '{print $1}'`
	if [ -n $DOAjobid ]; then	
		scancel $DOAjobid
		echo "$DOAjobid $line" >> log/HPLresults.$postfix
	fi
done
