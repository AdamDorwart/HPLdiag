#!/bin/bash
#
# Launch HPL diagnostics on all nodes in the provided host file

postfix=`date +'%m%d%y'`
# Print header to logs
echo "Starting HPLmon diagnostics on Comet (`date`)" >> log/HPLresults.$postfix
echo "-----------------------------------------------------------" >> log/HPLresults.$postfix

# Visual spinner
spinq="/-\|"
update_spinner() {
        spinf=${spinq#?}
        printf "Dispatching jobs [%c] " "$spinq"
        spinq=$spinf${spinq%"$spinf"}
        printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
}

while read line; do
	# Get node and partition from input file
	node=`echo $line | awk '{ print $1}'`
	partition=`echo $line | awk '{ print $2}'`
	# Dispatch job based on the partition
	# Default to compute partition if none given
	if [ "$partition" == "compute" -o "$partition" == "shared" ]; then
		sbatch --nodelist=$node --partition=$partition CPU/hpl_1n_12p_2t.comet $postfix > /dev/null
	elif [ "$partition" == "gpu" -o "$partition" == "gpu-shared" ]; then
		# Run both CPU and GPU tests on GPU nodes
		sbatch --nodelist=$node --partition=$partition CPU/hpl_1n_12p_2t.comet $postfix > /dev/null
		#TODO: Need AMBER GPU tests as well as CPU/GPU HPL tests
	elif [ "$partition" == "" ]; then
		sbatch --nodelist=$node --partition="compute" CPU/hpl_1n_12p_2t.comet $postfix > /dev/null
	fi
	update_spinner
done < $1
# Cancel all jobs for nodes that are down, failed, or in maintenece
# *the sed one-liner changes the node list from newline to comma delimited
queued_nodes=`squeue -h -o %n -u $USER | sed ':a;N;$!ba;s/\n/,/g'`
sinfo --format="%n %T %E" --nodes="$queued_nodes" --noheader | sort -u | grep -e "maint" -e "down" -e "drained" -e "fail" | while read line; do
	DOAnode=`echo $line | awk '{print $1}'`
	DOAjobid=`squeue --format="%i %n" -u $USER | grep $DOAnode | awk '{print $1}'`
	if [ -n $DOAjobid ]; then	
		scancel $DOAjobid &> /dev/null
		echo "$DOAjobid $line" >> log/HPLresults.$postfix
	fi
done
