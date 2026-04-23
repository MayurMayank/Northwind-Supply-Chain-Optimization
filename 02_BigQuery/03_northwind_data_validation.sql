-- DATA QUALITY ASSURANCE (QA) & VALIDATION CHECKS


-- VALIDATION 1: Ensure no revenue leakage occurred during table joins
-- Comparing the sum of netRevenue in the raw details table vs the final master table
SELECT 
    (SELECT ROUND(SUM(netRevenue), 2) FROM `northwind-supply-chain.northwind_raw.cleaned_order_details`) AS original_revenue,
    (SELECT ROUND(SUM(netRevenue), 2) FROM `northwind-supply-chain.northwind_raw.master_supply_chain_data`) AS master_table_revenue;
-- Expected Outcome: Both numbers must match exactly.

-- VALIDATION 2: Confirm distinct order count matches expected volume
SELECT 
    COUNT(DISTINCT orderID) AS total_unique_orders 
FROM `northwind-supply-chain.northwind_raw.master_supply_chain_data`;
-- Expected Outcome: 830