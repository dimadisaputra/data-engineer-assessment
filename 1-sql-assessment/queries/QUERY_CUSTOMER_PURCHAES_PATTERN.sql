-- Write a query to identify:
-- - Products that are frequently bought together
-- - Minimum basket size of 2 items
-- - Show product pairs, frequency of co-occurrence
-- - Filter for combinations occurring at least 10 times
-- Include product names and categories
-- Order by co-occurrence frequency

SELECT 
    p1.product_name AS product_a_name,
    p2.product_name AS product_b_name,
    p1.category_l1 AS product_a_category,
    p2.category_l1 AS product_b_category,
    COUNT(*) AS co_occurrence_frequency
FROM sales_line_items sli1
JOIN sales_line_items sli2 
    ON sli1.transaction_id = sli2.transaction_id 
    AND sli1.product_code < sli2.product_code
JOIN product_hierarchy p1 
    ON sli1.product_code = p1.product_code
JOIN product_hierarchy p2 
    ON sli2.product_code = p2.product_code
GROUP BY 
    p1.product_name, 
    p2.product_name, 
    p1.category_l1, 
    p2.category_l1
HAVING COUNT(*) >= 10
ORDER BY co_occurrence_frequency DESC;

