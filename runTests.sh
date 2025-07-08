#! /bin/bash
TIME=900
conn=100

# Connection flags
PGFLAGS="--db-driver=pgsql --pgsql-host=localhost --pgsql-port=3333 --pgsql-user=sbtest --pgsql-password=sbtest --pgsql-db=sf100"

XTRAFLAGS="--forced-shutdown=0"
# Creates the dir
[[ ! -d results ]] && mkdir results

# Outer loop for number of connections
# Creates a subdir to that number of connections
[[ ! -d results/${conn}_connections ]] && mkdir results/${conn}_connections
	
# NO Q2 test
./tpcc.lua ${PGFLAGS} --threads=${conn} --time=${TIME} run \
> results/${conn}_connections/NOQ2.out
echo "${conn} Connections no Q2"

sleep 60

# Inner loop for size of the batch
for batch_size in 10 100 1000
do
	# Q2 on the first position
	./tpcc.lua ${PGFLAGS} ${XTRAFLAGS} --threads=${conn} --time=${TIME} --batch_size=${batch_size} --include_q2 --batch_position=1 run \
	> results/${conn}_connections/${batch_size}_1stPosition.out
	echo "${conn} Connections ${batch_size} batch and Q2 in first"
		
	sleep 60

	# Q2 at the middle of the batch
	./tpcc.lua ${PGFLAGS} ${XTRAFLAGS} --threads=${conn} --time=${TIME} --batch_size=${batch_size} --include_q2 --batch_position=$((batch_size/2)) run \
	> results/${conn}_connections/${batch_size}_halfPosition.out
	echo "${conn} Connections ${batch_size} batch and Q2 halfway"

	sleep 60
	
	# Q2 at the end
	./tpcc.lua ${PGFLAGS} ${XTRAFLAGS} --threads=${conn} --time=${TIME} --batch_size=${batch_size} --include_q2 --batch_position=${batch_size} run \
	> results/${conn}_connections/${batch_size}_lastPosition.out
	echo "${conn} Connections ${batch_size} batch and Q2 at last"

	sleep 60

	# Q2 being selected at random (1/batch_size probability)
	./tpcc.lua ${PGFLAGS} ${XTRAFLAGS} --threads=${conn} --time=${TIME} --batch_size=${batch_size} --include_q2 run \
	> results/${conn}_connections/${batch_size}_randomPosition.out
	echo "${conn} Connections ${batch_size} batch and Q2 at random"
done
