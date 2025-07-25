#! /bin/bash

for conn in `ls | grep connections`
do
	NOQ2=${conn}/threads/NOQ2
	Q2R=${conn}/threads/Q2R
	Q2F=${conn}/threads/Q2F
	Q2L=${conn}/threads/Q2L
	for dir in $NOQ2 $Q2R $Q2F $Q2L
	do
		rm -rf ${dir}/resume{Q2,NO,PA}
		for file in `ls $dir | grep time_thread`
		do
			[[ $dir != $NOQ2 ]] && \
			cat $dir/$file | head -1 | cut -f3 >> $dir/resumeQ2

			cat $dir/$file | tail -2 | head -1 | cut -f2 >>	$dir/resumeNO
			cat $dir/$file | tail -1 | cut -f2 >> $dir/resumePA
		done
	done
done
