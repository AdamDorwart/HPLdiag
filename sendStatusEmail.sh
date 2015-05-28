#!/bin/bash
timedOut=`grep TIMEOUT log/$1 | awk '{print $4}' | sort`
awk -v timeout="$timedOut" '{ gsub("%TIMEOUT%",timeout); print}' ./statusEmail.txt | mail -s "Comet HPL Diagnostic Results" adamjdorwart@gmail.com
