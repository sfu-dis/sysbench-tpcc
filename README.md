# dis sysbench tpcc
This directory is a fork from https://github.com/Percona-Lab/sysbench-tpcc

The tests are scheduled by tpcc.lua, the usage is shown in runTests.sh, and the
 bash script could be adapted to run basically any test. 


## Code changes
Some adaptations were made to run tests according to the needs of this project.

Most of the changes were made at tpcc.lua, including functions to calculate
time delays outside of sysbench's core. There is also changes on tpcc_run.lua, 
as we wanted to isolate each client thread to it's own warehouse, so there 
would be no conflict between different client threads. This is visible at lines 
77 and 270 of tpcc_run.lua, where the variable corresponding to the warehouse 
selected has the same value of the thread id. This way, the first client 
thread will operate on the warehouse 1, the second thread on the warehouse 2 
and so on.

The tpcc_common.lua has changes too, since the original tpcc benchmark doesn't 
include q2. The new options implemented are:

* thread_file
	A name under a directory. Each thread will create its own file storing the
mean of all scheduling delays on its run. If the name given is "time_file", for 
example, the first thread will create the file "time_file_0", the second one 
will create "time_file_1" and so on.

* include_q2
	If set, sysbench will schedule q2 along new order and payment transactions. 
By default, the script will schedule batches of 10 queries and put q2 on a 
random position between then.
	
* batch_size
	If include_q2 is not set, this flag is ignored. Otherwise, the scheduled 
batch has the given size. For example, if batch_size is 100, the q2 will be 
scheduled once for every 100 transactions.

* batch_position
	If include_q2 is not set, this flag is ignored. Otherwise, q2 will be 
scheduled on the given position instead of randomly.


## Tests

The main tests where done by the script runTests.sh. It is a great interface to 
run any needed test. Usually it is run on tmux session so it is not fixed to
the ssh session. The results to the tests run until this point are under the 
results directory. The list of runned tests are the following:

* generic_threads
	Every thread runs q2, new order and payment queries. Those tests were run 
before implementing the warehouse separation by client threads.

* specialist_thread
	The only test made with one specialist thread running just Q2, the other 
threads ran new order and payment transactions	

* exclusiveWh
	The first tests run with exclusiveness for warehouses on each thread.

* exclusiveNewtime
	Ran tests with exclusive warehouses and saving the scheduling times.

* finalTests
	The same as exclusiveNewtime, but the results are separated by transaction
type. These are the most complete tests done, there is a README.MD under that
directory to explain the tests done and the scripts used to gather the 
statistics.
