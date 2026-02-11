-- Branch Details
INSERT INTO branch_details (branch_code, branch_name, region_id, operation_start_date, is_active, max_capacity, last_renovation_date) VALUES
('BR001', 'Central Jakarta', 1, '2020-01-01', TRUE, 1000, '2023-05-15'),
('BR002', 'West Jakarta', 1, '2021-03-12', TRUE, 800, '2024-01-10'),
('BR003', 'South Jakarta', 1, '2022-06-20', TRUE, 1200, NULL),
('BR004', 'North Jakarta', 2, '2019-11-25', TRUE, 1500, '2022-12-05'),
('BR005', 'East Jakarta', 2, '2023-01-15', TRUE, 700, NULL),
('BR006', 'Bandung Central', 3, '2018-05-10', TRUE, 2000, '2023-11-12'),
('BR007', 'Surabaya East', 4, '2020-08-14', TRUE, 1800, '2024-06-01'),
('BR008', 'Medan North', 5, '2021-12-01', TRUE, 900, NULL),
('BR009', 'Makassar South', 6, '2022-09-18', TRUE, 1100, NULL),
('BR010', 'Denpasar Main', 7, '2017-02-28', TRUE, 1300, '2023-01-20');

-- Staff Records
-- Note: Some active in 2023, some resigned
INSERT INTO staff_records (staff_id, branch_code, join_date, role_code, base_salary, supervisor_id, resignation_date, performance_score) VALUES
('STF001', 'BR001', '2020-02-01', 'MGR', 15000000.00, NULL, NULL, 4.50),
('STF002', 'BR001', '2022-05-15', 'SLS', 7000000.00, 'STF001', NULL, 4.20),
('STF003', 'BR002', '2021-04-10', 'SLS', 6500000.00, NULL, NULL, 3.80),
('STF004', 'BR002', '2023-01-10', 'SLS', 6500000.00, 'STF003', NULL, 4.60),
('STF005', 'BR003', '2022-07-01', 'CASH', 5500000.00, NULL, '2024-01-15', 4.00), -- Resigned in 2024 (Active in 2023)
('STF006', 'BR004', '2019-12-01', 'MGR', 16000000.00, NULL, NULL, 4.80),
('STF007', 'BR004', '2022-11-20', 'SLS', 6800000.00, 'STF006', '2023-08-30', 3.50), -- Resigned in 2023
('STF008', 'BR005', '2023-01-20', 'CASH', 5500000.00, NULL, NULL, 4.10),
('STF009', 'BR006', '2018-06-15', 'MGR', 17000000.00, NULL, NULL, 4.90),
('STF010', 'BR006', '2022-01-10', 'SLS', 7200000.00, 'STF009', NULL, 4.30);

-- Product Hierarchy
INSERT INTO product_hierarchy (product_code, product_name, category_l1, category_l2, category_l3, unit_cost, unit_price, supplier_id, minimum_stock, is_perishable) VALUES
('PROD001', 'Indomie Goreng', 'Food', 'Instant Noodles', 'Fried Noodles', 2500.00, 3100.00, 'SUP001', 500, FALSE),
('PROD002', 'Coca Cola 250ml', 'Beverage', 'Carbonated', 'Cola', 4000.00, 6000.00, 'SUP002', 200, FALSE),
('PROD003', 'Fresh Milk 1L', 'Food', 'Dairy', 'Liquid Milk', 15000.00, 22000.00, 'SUP003', 50, TRUE),
('PROD004', 'Sliced Bread', 'Food', 'Bakery', 'White Bread', 12000.00, 18000.00, 'SUP003', 30, TRUE),
('PROD005', 'Bango Sweet Soy Sauce', 'Food', 'Condiment', 'Soy Sauce', 10000.00, 14500.00, 'SUP004', 100, FALSE),
('PROD006', 'Lifebuoy Soap', 'Non-Food', 'Personal Care', 'Bath Soap', 3500.00, 5000.00, 'SUP005', 300, FALSE),
('PROD007', 'Sunlight Dishsoap', 'Non-Food', 'Home Care', 'Dishwashing', 12000.00, 16000.00, 'SUP005', 100, FALSE),
('PROD008', 'Pampers Size M', 'Non-Food', 'Baby Care', 'Diapers', 80000.00, 110000.00, 'SUP006', 40, FALSE),
('PROD009', 'Chitato Potato Chips', 'Food', 'Snacks', 'Potato Chips', 8000.00, 12000.00, 'SUP001', 150, FALSE),
('PROD010', 'Aqua 600ml', 'Beverage', 'Mineral Water', 'Plain Water', 3000.00, 4500.00, 'SUP007', 1000, FALSE);

-- Inventory Movements
-- Covers last 3 months (Nov 2025 - Jan 2026) for Stock Analysis
INSERT INTO inventory_movements (movement_id, product_code, branch_code, transaction_type, quantity, transaction_date, batch_number, expiry_date, unit_cost_at_time) VALUES
(1, 'PROD001', 'BR001', 'IN ', 1000, '2025-11-01', 'B1-001', NULL, 2500.00),
(2, 'PROD001', 'BR001', 'OUT', 200, '2025-11-15', 'B1-001', NULL, 2500.00),
(3, 'PROD003', 'BR001', 'IN ', 100, '2025-12-01', 'B1-002', '2026-01-01', 15000.00),
(4, 'PROD003', 'BR001', 'EXP', 10, '2026-01-02', 'B1-002', '2026-01-01', 15000.00),
(5, 'PROD002', 'BR002', 'IN ', 500, '2025-11-10', 'B2-001', NULL, 4000.00),
(6, 'PROD002', 'BR002', 'OUT', 450, '2025-12-20', 'B2-001', NULL, 4000.00),
(7, 'PROD010', 'BR001', 'IN ', 2000, '2025-11-01', 'B1-003', NULL, 3000.00),
(8, 'PROD010', 'BR001', 'OUT', 1800, '2025-12-15', 'B1-003', NULL, 3000.00),
(9, 'PROD004', 'BR003', 'IN ', 50, '2026-01-20', 'B3-001', '2026-01-27', 12000.00),
(10, 'PROD004', 'BR003', 'OUT', 30, '2026-01-25', 'B3-001', '2026-01-27', 12000.00),
(11, 'PROD001', 'BR001', 'OUT', 300, '2026-01-10', 'B1-001', NULL, 2500.00),
(12, 'PROD002', 'BR002', 'IN ', 200, '2026-01-05', 'B2-002', NULL, 4000.00);

-- Sales Transactions
-- Covers 2023 for Staff Performance
-- Covers frequent co-occurrence (PROD001 and PROD010 together 10+ times)
INSERT INTO sales_transactions (transaction_id, branch_code, transaction_date, staff_id, payment_method, total_amount, discount_amount, loyalty_points_earned, loyalty_points_redeemed, customer_id) VALUES
('TX2023001', 'BR001', '2023-01-15 10:00:00', 'STF002', 'CASH', 7600.00, 0.00, 7, 0, 'CUST001'),
('TX2023002', 'BR001', '2023-01-15 11:00:00', 'STF002', 'QRIS', 7600.00, 0.00, 7, 0, 'CUST002'),
('TX2023003', 'BR001', '2023-01-15 12:00:00', 'STF002', 'CASH', 7600.00, 0.00, 7, 0, 'CUST003'),
('TX2023004', 'BR001', '2023-02-10 14:00:00', 'STF002', 'CREDIT', 7600.00, 0.00, 7, 0, 'CUST004'),
('TX2023005', 'BR001', '2023-02-12 15:30:00', 'STF002', 'CASH', 7600.00, 0.00, 7, 0, 'CUST005'),
('TX2023006', 'BR001', '2023-03-05 09:15:00', 'STF002', 'QRIS', 7600.00, 0.00, 7, 0, 'CUST006'),
('TX2023007', 'BR001', '2023-03-20 18:45:00', 'STF002', 'CASH', 7600.00, 0.00, 7, 0, 'CUST007'),
('TX2023008', 'BR001', '2023-04-10 10:20:00', 'STF002', 'CREDIT', 7600.00, 0.00, 7, 0, 'CUST008'),
('TX2023009', 'BR001', '2023-04-15 13:40:00', 'STF002', 'CASH', 7600.00, 0.00, 7, 0, 'CUST009'),
('TX2023010', 'BR001', '2023-05-01 11:10:00', 'STF002', 'QRIS', 7600.00, 0.00, 7, 0, 'CUST010'),
('TX2023011', 'BR002', '2023-06-12 14:20:00', 'STF004', 'CASH', 50000.00, 5000.00, 45, 0, 'CUST011'),
('TX2023012', 'BR003', '2023-08-10 09:30:00', 'STF005', 'QRIS', 35000.00, 0.00, 35, 0, 'CUST012');

-- Sales Line Items
-- Ensure PROD001 and PROD010 co-occur in the first 10 transactions
INSERT INTO sales_line_items (transaction_id, line_number, product_code, quantity, unit_price_at_time, discount_percentage, total_line_amount) VALUES
('TX2023001', 1, 'PROD001', 1, 3100.00, 0.00, 3100.00),
('TX2023001', 2, 'PROD010', 1, 4500.00, 0.00, 4500.00),
('TX2023002', 1, 'PROD001', 1, 3100.00, 0.00, 3100.00),
('TX2023002', 2, 'PROD010', 1, 4500.00, 0.00, 4500.00),
('TX2023003', 1, 'PROD001', 1, 3100.00, 0.00, 3100.00),
('TX2023003', 2, 'PROD010', 1, 4500.00, 0.00, 4500.00),
('TX2023004', 1, 'PROD001', 1, 3100.00, 0.00, 3100.00),
('TX2023004', 2, 'PROD010', 1, 4500.00, 0.00, 4500.00),
('TX2023005', 1, 'PROD001', 1, 3100.00, 0.00, 3100.00),
('TX2023005', 2, 'PROD010', 1, 4500.00, 0.00, 4500.00),
('TX2023006', 1, 'PROD001', 1, 3100.00, 0.00, 3100.00),
('TX2023006', 2, 'PROD010', 1, 4500.00, 0.00, 4500.00),
('TX2023007', 1, 'PROD001', 1, 3100.00, 0.00, 3100.00),
('TX2023007', 2, 'PROD010', 1, 4500.00, 0.00, 4500.00),
('TX2023008', 1, 'PROD001', 1, 3100.00, 0.00, 3100.00),
('TX2023008', 2, 'PROD010', 1, 4500.00, 0.00, 4500.00),
('TX2023009', 1, 'PROD001', 1, 3100.00, 0.00, 3100.00),
('TX2023009', 2, 'PROD010', 1, 4500.00, 0.00, 4500.00),
('TX2023010', 1, 'PROD001', 1, 3100.00, 0.00, 3100.00),
('TX2023010', 2, 'PROD010', 1, 4500.00, 0.00, 4500.00),
('TX2023011', 1, 'PROD008', 1, 110000.00, 50.00, 55000.00),
('TX2023012', 1, 'PROD003', 1, 22000.00, 0.00, 22000.00),
('TX2023012', 2, 'PROD004', 1, 18000.00, 0.00, 18000.00);
