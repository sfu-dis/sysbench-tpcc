#! /bin/bash

for conn in `ls | grep connections`
do
	NOQ2=${conn}/threads/NOQ2
	Q2R=${conn}/threads/Q2R
	Q2F=${conn}/threads/Q2F
	Q2L=${conn}/threads/Q2L
	for dir in $NOQ2 $Q2R $Q2F $Q2L
	do
		for file in `ls`
		do
			[[ $dir != $NOQ2 ]] && \
			./summ.py $dir/resumeQ2 > $dir/meanQ2

			./summ.py $dir/resumeNO > $dir/meanNO
			./summ.py $dir/resumePA > $dir/meanPA
		done
	done
done
