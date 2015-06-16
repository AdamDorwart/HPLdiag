#!/bin/bash
#
# Cancels all running jobs for the current user and logs the action

# Set to false to cancel all queued jobs
#RUNNING_JOBS=false

postfix=`date +'%m%d%y'`
queuedJobs=`squeue --format="%n %i %R" --noheader --user=$USER`
#if [ "$RUNNING_JOBS" == true ]; then
#	queuedJobs=`echo "$queuedJobs" | grep "comet"`
#fi
echo "$queuedJobs" | while read line; do 
	DOAjobid=`echo $line | awk '{ print $2}'`
	DOAnode=`echo $line | awk '{ print $1}'`
	scancel $DOAjobid > /dev/null
	echo "$DOAjobid $DOAnode canceled before completion" >> log/HPLresults.$postfix
done

