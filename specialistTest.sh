#! /bin/bash
TIME=600
conn=100

# Connection flags
PGFLAGS="--db-driver=pgsql --pgsql-host=localhost --pgsql-port=3333 --pgsql-user=sbtest --pgsql-password=sbtest --pgsql-db=sf100"

XTRAFLAGS="--forced-shutdown=0"

for CONN in 10 50 100
do
	echo $CONN
	./tpcc.lua ${PGFLAGS} ${XTRAFLAGS} --threads=${CONN} --time=${TIME} run \
	> results_specialistThread/${CONN}_connections/NOQ2.out

	./tpcc.lua ${PGFLAGS} ${XTRAFLAGS} --threads=${CONN} --time=${TIME} --include_q2 run \
	> results_specialistThread/${CONN}_connections/Q2.out
done
