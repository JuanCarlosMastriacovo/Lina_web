SHOW PROCESSLIST;
SHOW VARIABLES LIKE 'max_connections';
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Max_used_connections';
SHOW VARIABLES LIKE '%buffer%';
SHOW VARIABLES LIKE '%timeout%';
SELECT 
    (1 - (Variable_value / 
    (SELECT Variable_value FROM performance_schema.global_status WHERE Variable_name = 'Innodb_buffer_pool_read_requests'))) * 100 AS Hit_Rate
FROM performance_schema.global_status 
WHERE Variable_name = 'Innodb_buffer_pool_reads';
