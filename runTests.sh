#! /bin/bash
# This script is a good example of scheduling differente tests with sysbench,

# Connection flags
PGFLAGS="--db-driver=pgsql --pgsql-host=localhost --pgsql-port=3333 --pgsql-user=sbtest --pgsql-password=sbtest --pgsql-db=sf100"

CONN=100						# Number of threads
OUTDIR="results/finalTests"		# Destination files

# Flags for all tests
COMMONFLAGS="${PGFLAGS} --batch_size=10 --threads=${CONN}" 

# Creates the dir
[[ ! -d ${OUTDIR} ]] && mkdir ${OUTDIR}

# Creates a subdir to that number of connections
[[ ! -d ${OUTDIR}/${CONN}_connections ]] && mkdir ${OUTDIR}/${CONN}_connections \
&& mkdir ${OUTDIR}/${CONN}_connections/threads \
&& mkdir ${OUTDIR}/${CONN}_connections/threads/NOQ2 \
&& mkdir ${OUTDIR}/${CONN}_connections/threads/Q2{R,F,L}

	
# Run new order and payment transactions only
./tpcc.lua \
	${COMMONFLAGS} \
	--time=10 \
	--thread_file=${OUTDIR}/${CONN}_connections/threads/NOQ2/time_thread run \
	> ${OUTDIR}/${CONN}_connections/NOQ2.out

echo "${CONN} Connections no Q2"
sleep 60 # Needed because postgres takes some time to close the created connections

# 10% of queries are Q2 and their position in batches of 10 is random
./tpcc.lua \
	${COMMONFLAGS} \
	--time=600 \
	--thread_file=${OUTDIR}/${CONN}_connections/threads/Q2R/time_thread \
	--include_q2 run \
	> ${OUTDIR}/${CONN}_connections/Q2R.out
echo "${CONN} Connections with Q2 at random"
sleep 60

./tpcc.lua ${COMMONFLAGS} --time=600 --batch_position=1 --thread_file=${OUTDIR}/${CONN}_connections/threads/Q2F/time_thread --include_q2 run \
> ${OUTDIR}/${CONN}_connections/Q2F.out
echo "${CONN} Connections with Q2 at first"
sleep 60

./tpcc.lua ${COMMONFLAGS} --time=600 --batch_position=10 --thread_file=${OUTDIR}/${CONN}_connections/threads/Q2L/time_thread --include_q2 run \
> ${OUTDIR}/${CONN}_connections/Q2L.out
echo "${CONN} Connections with Q2 at last"
sleep 60
