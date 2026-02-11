-- Calculate inventory turnover metrics per branch
-- Write a query to show:
-- - Branch name
-- - Total incoming stock (IN transactions)
-- - Total outgoing stock (OUT transactions)
-- - Current stock level
-- - Number of expired items (EXP transactions)
-- For the last 3 months, ordered by highest stock turnover rate

-- Stock Turnover Ratio = Cost of Goods Sold (COGS) ÷ Average Inventory
-- Average Inventory = (Beginning Inventory + Ending Inventory) ÷ 2

WITH inventory_calc AS (
    SELECT
        bd.branch_code,
        bd.branch_name,

        -- Beginning Stock
        SUM(CASE 
            WHEN im.transaction_date < CURRENT_DATE - INTERVAL '3 month' THEN
                CASE 
                    WHEN im.transaction_type = 'IN' THEN im.quantity
                    WHEN im.transaction_type IN ('OUT', 'EXP') THEN -im.quantity
                    ELSE 0
                END
            ELSE 0
        END) AS beginning_stock,

        -- Last 3 Months
        SUM(CASE
            WHEN im.transaction_date >= CURRENT_DATE - INTERVAL '3 month'
            THEN 
                CASE
                    WHEN im.transaction_type = 'IN' THEN im.quantity
                    ELSE 0
                END
            ELSE 0
        END) AS stock_in_period,

        SUM(CASE
            WHEN im.transaction_date >= CURRENT_DATE - INTERVAL '3 month'
            THEN 
                CASE
                    WHEN im.transaction_type = 'OUT' THEN im.quantity
                    ELSE 0
                END
            ELSE 0
        END) AS stock_out_period,

        SUM(CASE
            WHEN im.transaction_date >= CURRENT_DATE - INTERVAL '3 month'
            THEN 
                CASE
                    WHEN im.transaction_type = 'EXP' THEN im.quantity
                    ELSE 0
                END
            ELSE 0
        END) AS stock_exp_period
    FROM branch_details bd
    LEFT JOIN inventory_movements im 
        ON bd.branch_code = im.branch_code
    GROUP BY bd.branch_code, bd.branch_name
),
final_metrics AS (
    SELECT
        *,
        -- ending inventory
        (beginning_stock + stock_in_period - stock_out_period - stock_exp_period) AS ending_stock
    FROM inventory_calc
)
SELECT 
    branch_name,
    stock_in_period AS total_incoming_stock,
    stock_out_period AS total_outgoing_stock,
    ending_stock AS current_stock_level,
    stock_exp_period AS number_of_expired_items,
    CASE 
        WHEN (beginning_stock + ending_stock) / 2.0 = 0 THEN 0
        ELSE stock_out_period / ((beginning_stock + ending_stock) / 2.0)
    END AS stock_turnover_rate
FROM final_metrics
ORDER BY stock_turnover_rate DESC;