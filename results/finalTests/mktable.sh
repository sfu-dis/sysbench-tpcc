#! /bin/bash

for transaction in Q2 NO PA
do
	L1="x\t\t,1\t\t\t,10\t\t\t,50\t\t\t,100\t\t\t"
	L2="NOQ2\t\t"
	L3="Q2Random\t"
	L4="Q2First\t\t"
	L5="Q2Last\t\t"
	for i in {1,10,50,100}
	do
		[[ ${transaction} != Q2 ]] && \
		NOQ2=`cat ${i}_connections/threads/NOQ2/mean${transaction}`
		Q2R=`cat ${i}_connections/threads/Q2R/mean${transaction}`
		Q2F=`cat ${i}_connections/threads/Q2F/mean${transaction}`
		Q2L=`cat ${i}_connections/threads/Q2L/mean${transaction}`

		L2="${L2},${NOQ2}\t"
		L3="${L3},${Q2R}\t"
		L4="${L4},${Q2F}\t"
		L5="${L5},${Q2L}\t"
	done
	
	if [[ ${transaction} != Q2 ]]
	then
		echo -e "${L1}\n${L2}\n${L3}\n${L4}\n${L5}" > table${transaction}
	else
		echo -e "${L1}\n${L3}\n${L4}\n${L5}" > table${transaction}
	fi
done
