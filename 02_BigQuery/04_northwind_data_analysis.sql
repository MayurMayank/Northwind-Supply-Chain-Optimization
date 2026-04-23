-- ANALYSIS: Shipping Performance & Freight Cost (Unique Orders)

WITH order_level AS (
  SELECT DISTINCT
    orderID,
    shipperName,
    freight,
    shippingStatus
  FROM
    `northwind-supply-chain.northwind_raw.master_supply_chain_data`
)
SELECT
  shipperName,
  COUNT(orderID) AS totalOrders,
  COUNT(CASE WHEN shippingStatus = 'Delayed' THEN orderID END) AS delayedOrders,
  ROUND(COUNT(CASE WHEN shippingStatus = 'Delayed' THEN orderID END) * 100.0 / COUNT(orderID), 2) AS delayPercentage,
  ROUND(AVG(freight), 2) AS avgFreightCost
FROM
  order_level
GROUP BY
  shipperName
ORDER BY
  delayPercentage DESC;


-- ADVANCED ANALYSIS: Top Categories & Revenue Contribution (Using CTE and Window Functions)

WITH CategoryMetrics AS (
  -- Step 1: Aggregate the base metrics per category
  SELECT
    categoryName,
    COUNT(DISTINCT orderID) AS totalOrders,
    SUM(quantity) AS totalUnitsSold,
    SUM(netRevenue) AS categoryRevenue
  FROM
    `northwind-supply-chain.northwind_raw.master_supply_chain_data`
  WHERE
    categoryName IS NOT NULL
  GROUP BY
    categoryName
),
RankedCategories AS (
  -- Step 2: Apply Window Functions for Ranking and Percentages
  SELECT
    categoryName,
    totalOrders,
    totalUnitsSold,
    ROUND(categoryRevenue, 2) AS totalNetRevenue,
    -- Window function to calculate the % of Total Company Revenue
    ROUND((categoryRevenue / SUM(categoryRevenue) OVER ()) * 100, 2) AS pctOfTotalRevenue,
    -- Window function to rank them
    DENSE_RANK() OVER (ORDER BY categoryRevenue DESC) as revenueRank
  FROM
    CategoryMetrics
)
-- Step 3: Filter for the Top 3
SELECT 
  revenueRank,
  categoryName,
  totalOrders,
  totalUnitsSold,
  totalNetRevenue,
  pctOfTotalRevenue
FROM 
  RankedCategories
WHERE 
  revenueRank <= 3
ORDER BY 
  revenueRank;


-- ANALYSIS: Shipping Delays by Geography (Using Subquery)

SELECT 
  shipCountry,
  totalOrders,
  delayedOrders,
  delayRatePct
FROM (
  -- Inner Subquery: Calculates all the metrics per country using UNIQUE orders
  SELECT
    shipCountry,
    COUNT(DISTINCT orderID) AS totalOrders,
    COUNT(DISTINCT CASE WHEN shippingStatus = 'Delayed' THEN orderID END) AS delayedOrders,
    ROUND((COUNT(DISTINCT CASE WHEN shippingStatus = 'Delayed' THEN orderID END) / COUNT(DISTINCT orderID)) * 100, 2) AS delayRatePct
  FROM
    `northwind-supply-chain.northwind_raw.master_supply_chain_data`
  WHERE
    shipCountry IS NOT NULL
  GROUP BY
    shipCountry
) AS CountryMetrics
WHERE 
  totalOrders >= 5
ORDER BY 
  delayedOrders DESC;