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

function payment_new_order_only(times)
	for i=1, times
	do
		trx_type = sysbench.rand.uniform(0, 1)
		_G[(trx_type == 1) and "new_order" or "payment"]()
	end
end

function q2_included()
	if sysbench.opt.batch_position == 0
	then
		q2 = sysbench.rand.uniform(1, sysbench.opt.batch_size)
		if q2 == 1 then
			_G["q2_adapted"]()
		else
			no = sysbench.rand.uniform(0, 1)
			_G[(no==1) and "new_order" or "payment"]()
		end
	else
		payment_new_order_only(sysbench.opt.batch_position-1)
		_G["q2_adapted"]()
		payment_new_order_only(sysbench.opt.batch_size - sysbench.opt.batch_position)	
	end
end

function event()
	if sysbench.opt.include_q2 then
		q2_included()
	else
		payment_new_order_only(sysbench.opt.batch_size)
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
