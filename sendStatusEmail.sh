#!/bin/bash
header=`grep -e "---" -B 1 log/$1 | tail -2`
timedOut=`grep -e "HPL-TIMEOUT" log/$1 | awk '{print $4}' | sort`
if [ -z "$timedOut" ]; then
	timedOut="No jobs timed out"
fi
died=`grep -e "HPL-DIED" log/$1 | awk '{print $4}' | sort`
if [ -z "$died" ]; then
        died="No jobs died"
fi
failed=`grep -e "HPL-FAIL" log/$1 | awk '{print $4}' | sort`
if [ -z "$failed" ]; then
        failed="No jobs failed"
fi
awk -v header="$header" -v timeout="$timedOut" -v died="$died" -v failed="$failed" '{ gsub("%HEADER%",header); gsub("%TIMEOUT%",timeout); gsub("%DIED%",died); gsub("%FAILED%",failed); print}' ./statusEmail.txt | mail -s "Comet HPL Diagnostic Results" `cat statusMailingList | awk 'BEGIN {RS=""}{ gsub(/\n/,",");gsub(" ",""); print}'`
