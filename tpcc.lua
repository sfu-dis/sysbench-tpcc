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

function thread_init()
   drv,con=db_connection_init()
	print(sysbench.tid)
end


function payment_new_order()
	trx_type = sysbench.rand.uniform(0, 1)
	_G[(trx_type == 1) and "new_order" or "payment"]()
end

function event_aux()
	if sysbench.tid == 1 and sysbench.opt.include_q2
	then
		_G["q2_adapted"]()
	else
		payment_new_order()
	end
end

function event()
	if GCOUNTER == nil
	then
		GCOUNTER = 1
	end

	if sysbench.opt.batch_position == 0 and GPOS == nil
	then
		GPOS = sysbench.rand.uniform(1, sysbench.opt.batch_size)
	end

	if sysbench.opt.include_q2
	then
		if sysbench.opt.batch_position == 0 and GCOUNTER == GPOS
		then
			_G["q2_adapted"]()
		elseif GCOUNTER == sysbench.opt.batch_position
		then
			_G["q2_adapted"]()
		else
			payment_new_order()
		end
	else
		payment_new_order()
	end


	if GCOUNTER == sysbench.opt.batch_size
	then
		GCOUNTER = 1
		if sysbench.opt.batch_position == 0
		then
			GPOS = sysbench.rand.uniform(1, sysbench.opt.batch_size)
		end
	else
		GCOUNTER = GCOUNTER + 1	
	end
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
