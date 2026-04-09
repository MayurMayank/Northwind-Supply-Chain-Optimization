-- 1A. DATA CLEANING: Fixing Customer Table Headers
CREATE OR REPLACE TABLE `northwind-supply-chain.northwind_raw.cleaned_customers` AS
SELECT
  string_field_0 AS customerID,
  string_field_1 AS companyName,
  string_field_2 AS contactName,
  string_field_3 AS contactTitle,
  string_field_4 AS city,
  string_field_5 AS country
FROM 
  `northwind-supply-chain.northwind_raw.customers`
WHERE 
  string_field_0 != 'customerID';

-- 1B. DATA CLEANING: order_details (Precise Math & Net Revenue)
CREATE OR REPLACE TABLE `northwind-supply-chain.northwind_raw.cleaned_order_details` AS
SELECT 
    *, 
    ROUND(CAST((unitPrice * quantity * (1 - discount)) AS NUMERIC), 2) AS netRevenue
FROM `northwind-supply-chain.northwind_raw.order_details`;

-- 1C. DATA CLEANING: orders (Logistics Logic & Status)
CREATE OR REPLACE TABLE `northwind-supply-chain.northwind_raw.cleaned_orders` AS
SELECT 
    *, 
    CASE 
        WHEN shippedDate IS NULL THEN 'Unshipped'
        WHEN shippedDate > requiredDate THEN 'Delayed'
        ELSE 'On-Time'
    END AS shippingStatus
FROM `northwind-supply-chain.northwind_raw.orders`;


