SELECT 
    s.s_suppkey,       
    s.s_name,         
    n.n_name,       
    i.i_id,        
    i.i_name    
FROM supplier s
JOIN nation n ON s.s_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
JOIN stock st ON s.s_suppkey = (st.s_w_id * st.s_i_id) % 10000
JOIN item i ON st.s_i_id = i.i_id
WHERE 
    r.r_name = [TARGET_REGION]
    AND st.s_quantity = (
        SELECT MIN(st2.s_quantity)
        FROM stock st2
        WHERE st2.s_w_id = st.s_w_id
        AND st2.s_i_id = st.s_i_id
    )
    AND i.i_data NOT LIKE '%b%' 
ORDER BY 
    n.n_name, 
    s.s_name, 
    i.i_id;
