#!/bin/bash
#
# Send out a status email on a given HPL log to a mailing list
 
header=`grep -e "---" --before-context=1 log/$1 | tail -2`
timedOut=`grep -e "HPL-CPU-TIMEOUT" log/$1 | awk '{print $4}' | sort`
if [ -z "$timedOut" ]; then
	timedOut="No jobs timed out"
fi
died=`grep -e "HPL-CPU-DIED" log/$1 | awk '{print $4}' | sort`
if [ -z "$died" ]; then
        died="No jobs died"
fi
failed=`grep -e "HPL-CPU-FAIL" log/$1 | awk '{print $4}' | sort`
if [ -z "$failed" ]; then
        failed="No jobs failed"
fi
mailingList=`cat statusMailingList | awk 'BEGIN {RS=""}{ gsub(/\n/,",");gsub(" ",""); print}'`
awk -v header="$header" -v timeout="$timedOut" -v died="$died" -v failed="$failed" '{ gsub("%HEADER%",header); gsub("%TIMEOUT%",timeout); gsub("%DIED%",died); gsub("%FAILED%",failed); print}' ./statusEmail.txt \
  | mail -s "Comet HPL Diagnostic Results" $mailingList
