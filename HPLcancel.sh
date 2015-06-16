#!/bin/bash
#
# Cancels all running jobs for the current user and logs the action

postfix=`date +'%m%d%y'`
squeue --format="%R %i" -u $USER | grep "comet" | while read line; do 
	DOAjobid=`echo $line | awk '{ print $2}'`
	DOAnode=`echo $line | awk '{ print $1}'`
	scancel $DOAjobid
	echo "$DOAjobid $DOAnode canceled before completion" >> log/HPLresults.$postfix
done

