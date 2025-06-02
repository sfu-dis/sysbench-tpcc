#! /bin/bash

help() { echo "${0} -s [scale_number] -c [prepare|run|cleanup]" ; exit 1 ;}

THREADS=1
SCALE=1
COMMAND=""

while getopts "c:t:s:" o ;
do
	case "${o}" in
		t)
			THREADS=${OPTARG}
			;;
		s)
			SCALE=${OPTARG}
			;;
		c)
			[[ "${OPTARG}" != "prepare" && "${OPTARG}" != "run" && "${OPTARG}" != "cleanup" ]] && echo "ERROR: option '${OPTARG}' invalid" && help
			COMMAND=${OPTARG}
			;;
		*)
			help
			;;
	esac
done

./tpcc.lua \
--db-driver=pgsql \
--pgsql-host=localhost \
--pgsql-port=3333 \
--pgsql-user=sbtest \
--pgsql-password=sbtest \
--pgsql-db=sbtest \
--time=60 \
--threads=1 \
--scale=${1} \
${2}
