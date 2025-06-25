SELECT 
        s.su_suppkey,       
        s.su_name,         
        n.n_name,       
        i.i_id,        
        i.i_name    
FROM 
	supplier1 s
JOIN
	nation1 n
	ON s.su_nationkey = n.n_nationkey
JOIN region1 r
	ON n.n_regionkey = r.r_regionkey
JOIN stock1 st
	ON s.su_suppkey = (st.s_w_id * st.s_i_id) % 10000
JOIN item1 i
	ON st.s_i_id = i.i_id
WHERE 
	r.r_name = (
		SELECT r_name
		FROM region1
		LIMIT 1
	)
	AND st.s_quantity = (
		SELECT MIN(st2.s_quantity)
		FROM stock1 st2
		WHERE st2.s_w_id = st.s_w_id
		AND st2.s_i_id = st.s_i_id
	)
	AND i.i_data NOT LIKE '%b%' 
ORDER BY 
	n.n_name, 
	s.su_name, 
	i.i_id
;
