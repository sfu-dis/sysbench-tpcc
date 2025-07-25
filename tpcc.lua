#!/usr/bin/env sysbench

-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

-- ----------------------------------------------------------------------
-- TPCC-like workload
-- ----------------------------------------------------------------------

require("tpcc_common")
require("tpcc_run")
require("tpcc_check")

-- parses the output of date command to int value
function time_to_nanoseconds(time_str)
    local h, m, s, n = time_str:match("^(%d+):(%d+):(%d+):(%d+)$")
    h, m, s, n = tonumber(h), tonumber(m), tonumber(s), tonumber(n)
    return (((h * 60 + m) * 60 + s) * 1e9) + n
end

-- Subtracts two strings containing a date
function time_diff_ns(t1, t2)
    local ns1 = time_to_nanoseconds(t1)
    local ns2 = time_to_nanoseconds(t2)
    return ns1 - ns2
end

-- Captures current time with nanosseconds precision
function capture_time()
	local f = assert(io.popen('date +%H:%M:%S:%N', 'r'))
	local s = assert(f:read('*a'))
	f:close()
	
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end


function thread_init()
   drv,con=db_connection_init()
	print(sysbench.tid)
	
	-- Variables for thread time calculation
	if sysbench.opt.thread_file then
		-- This file stores scheduling times for each type of thread
		thread_file = io.open(sysbench.opt.thread_file.."_"..sysbench.tid, "w")
	end

	q2_tevents = 0 
	no_tevents = 0 
	pa_tevents = 0 
	q2_delayc = 0
	no_delayc = 0
	pa_delayc = 0
end

-- sorts between payment and new order transactions
function payment_new_order()
	trx_type = sysbench.rand.uniform(0, 1)
	if trx_type == 1 then
		TS_LAST = capture_time()
		_G["new_order"]()
		no_delayc = no_delayc + time_diff_ns(TS_LAST, TS_BEGIN)
		no_tevents = no_tevents+1
	else
		TS_LAST = capture_time()
		_G["payment"]()
		pa_delayc = pa_delayc + time_diff_ns(TS_LAST, TS_BEGIN)
		pa_tevents = pa_tevents+1
	end
end

function q2()
	TS_LAST = capture_time()
	_G["q2_adapted"]()
	q2_delayc = q2_delayc + time_diff_ns(TS_LAST, TS_BEGIN)
	q2_tevents = q2_tevents + 1
end

-- body of each thread spawned
function event(thread_id)
	if GCOUNTER == 1
	then
		TS_BEGIN =  capture_time()
	end
		
	if GCOUNTER == nil
	then
		TS_BEGIN = capture_time()
		GCOUNTER = 1
	end

	if sysbench.opt.batch_position == 0 and GPOS == nil
	then
		TS_LAST = capture_time()
		GPOS = sysbench.rand.uniform(1, sysbench.opt.batch_size)
	end

	if sysbench.opt.include_q2
	then
		if sysbench.opt.batch_position == 0 and GCOUNTER == GPOS
		then
			q2()
		elseif GCOUNTER == sysbench.opt.batch_position
		then
			q2()
		else
			payment_new_order()			
		end
	else
		payment_new_order()
	end


	if GCOUNTER == sysbench.opt.batch_size
	then
		if sysbench.opt.batch_position == 0
		then
			GPOS = sysbench.rand.uniform(1, sysbench.opt.batch_size)
		end
		GCOUNTER = 1
	else
		GCOUNTER = GCOUNTER + 1	
	end
end

-- called at the end of each thread. If --forced-shutdown is set, this will
-- never be executed
function thread_done()
	if thread_file ~= nil then
		if sysbench.opt.include_q2 then
			thread_file:write("q2:\t\t"..(q2_delayc/(q2_tevents*1000000)).."\n")
		end
		thread_file:write("new_order:\t"..((no_delayc)/(no_tevents*1000000)).."\npayment:\t"..((pa_delayc)/(pa_tevents*1000000)).."\n")
		thread_file:close()
	end
	-- Each thread has to write to its own file because lua creates a copy of
	-- the global table for each thread, so it can't aggregate these values
end

--##############################################################################
function sysbench.hooks.before_restart_event(err)
  con:query("ROLLBACK")
end

function sysbench.hooks.report_intermediate(stat)
-- --   print("my stat: ", val)
   if  sysbench.opt.report_csv == "yes" then
   	sysbench.report_csv(stat)
   else
   	sysbench.report_default(stat)
   end
end

-- vim:ts=4 ss=4 sw=4 expandtab
