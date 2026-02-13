-- Write a query to find:
-- - Staff ID
-- - Staff's branch name
-- - Number of transactions handled
-- - Total sales amount
-- - Average transaction value
-- - Performance score
-- Only for active staff (no resignation date) in 2023


SELECT
    sr.staff_id,
    bd.branch_name,
    COUNT(st.transaction_id) AS number_of_transactions,
    COALESCE(SUM(st.total_amount), 0) AS total_sales_amount,
    COALESCE(AVG(st.total_amount), 0) AS average_transaction_value,
    sr.performance_score
FROM staff_records sr
JOIN branch_details bd 
    ON sr.branch_code = bd.branch_code
LEFT JOIN sales_transactions st 
    ON sr.staff_id = st.staff_id
    AND st.transaction_date >= '2023-01-01' 
    AND st.transaction_date < '2024-01-01'
WHERE sr.resignation_date IS NULL 
GROUP BY sr.staff_id, bd.branch_name, sr.performance_score
ORDER BY number_of_transactions DESC;