#!/bin/bash
postfix=`date +'%m%d%y'`
squeue -o "%R %i" -u $USER | grep "comet" | while read line; do 
	DOAjobid=`echo $line | awk '{ print $2}'`
	DOAnode=`echo $line | awk '{ print $1}'`
	scancel $DOAjobid
	echo "$DOAjobid $DOAnode canceled before completion" >> log/HPLresults.$postfix
done

