-- 2. DATA TRANSFORMATION: Creating the Final Master Table
CREATE OR REPLACE TABLE `northwind-supply-chain.northwind_raw.master_supply_chain_data` AS
SELECT
  -- Order & Logistics Information
  o.orderID,
  o.orderDate,
  o.requiredDate,
  o.shippedDate,
  o.shippingStatus,  -- Pulled from our cleaned_orders
  o.freight,
  s.companyName AS shipperName,
  
  -- Financial & Product Information
  od.productID,
  p.productName,
  c.categoryName,
  od.unitPrice,
  od.quantity,
  od.discount,
  od.netRevenue,     -- Pulled from our cleaned_order_details
  
  -- Customer Information
  cu.companyName AS customerName,
  cu.country AS shipCountry

FROM 
  `northwind-supply-chain.northwind_raw.cleaned_orders` o
JOIN 
  `northwind-supply-chain.northwind_raw.cleaned_order_details` od ON o.orderID = od.orderID
JOIN 
  `northwind-supply-chain.northwind_raw.products` p ON od.productID = p.productID
JOIN 
  `northwind-supply-chain.northwind_raw.categories` c ON p.categoryID = c.categoryID
LEFT JOIN 
  `northwind-supply-chain.northwind_raw.cleaned_customers` cu ON o.customerID = cu.customerID 
LEFT JOIN 
  `northwind-supply-chain.northwind_raw.shippers` s ON o.shipperID = s.shipperID;