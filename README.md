# Northwind Traders: Supply Chain Optimization & Revenue Leakage Analysis

**Live Interactive Dashboard:** [View Executive Dashboard on Tableau Public](https://public.tableau.com/views/ExecutiveSupplyChainPerformanceDashboard/FinalDashboard?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

### Executive Summary
This project identifies operational inefficiencies and revenue leakage within Northwind Traders' global supply chain. By auditing over 2,100 shipment records and financial line items, this analysis isolates underperforming logistics providers, pinpoints geographic bottlenecks, and highlights critical product dependencies. The resulting insights provide a data-driven roadmap to reduce freight costs and protect core revenue streams for the upcoming fiscal quarter.

  <img width="1920" height="1080" alt="01_Dashboard_Default_View" src="https://github.com/user-attachments/assets/a59f8f59-d906-4156-978b-7b6048320733" />

*(Above: The overarching executive view of Northwind's supply chain performance.)*

---

## 1. The Business Problem (Ask Phase)

**The Scenario:** Northwind Traders requires a strategic review of its logistics efficiency (shipping delays and freight costs) and its financial performance (net revenue after discounts). 
**Primary Stakeholders:** VP of Operations & Finance Director.

### Key Business Metrics Defined:
* **On-Time Delivery (OTD) %:** Tracking the ratio of delayed orders against total unique invoices.
* **Average Freight Cost:** Measuring logistics expenditure per unique order.
* **Net Revenue:** Calculating true profitability `(Unit Price * Quantity) * (1 - Discount %)`.

### Core Business Questions:
1. Which shipping provider has the highest rate of late deliveries, and does paying more for freight guarantee faster shipping?
2. Which top 3 product categories contribute the most to Net Revenue after all discounts are applied?
3. Is there a correlation between specific regions (Ship Country) and high shipping delays?

---

## 2. Data Pipeline & Architecture (Prepare & Process Phase)

* **Tech Stack:** Google BigQuery (SQL), Python (Pandas, Seaborn), Tableau Public.
* **Data Source:** [Maven Analytics (Northwind Traders Relational Database)](https://mavenanalytics.io/data-playground/northwind-traders).

### ETL & Data Transformation (BigQuery SQL)
Raw data was extracted from 7 separate tables, cleaned, and joined into a single master view for downstream analysis. Key transformations included:
* **Header Standardization:** Rectified misaligned schemas in legacy customer tables.
* **Feature Engineering (Logistics):** Built a deterministic `shippingStatus` column comparing `requiredDate` vs. `shippedDate`.
* **Financial Math:** Calculated precise `netRevenue` at the line-item level.

```sql
-- Example: Financial calculation and logistics logic during Data Cleaning
CREATE OR REPLACE TABLE `northwind-supply-chain.northwind_raw.cleaned_orders` AS
SELECT 
    *, 
    CASE 
        WHEN shippedDate IS NULL THEN 'Unshipped'
        WHEN shippedDate > requiredDate THEN 'Delayed'
        ELSE 'On-Time'
    END AS shippingStatus
FROM `northwind-supply-chain.northwind_raw.orders`;
```

### Assumptions & Caveats
* **Shipping Status:** Orders with a `NULL` value in the `shippedDate` column were assumed to be "Unshipped" and were excluded from historical delay calculations.
* **Financial Calculations:** Net Revenue assumes that the `discount` field is applied at the line-item level prior to summing the final order total. 
* **Data Granularity:** Freight costs are recorded at the `orderID` level. To prevent inflating freight totals during logistics analysis, duplicate line items were dropped using Python (`df.drop_duplicates`) to ensure metrics were calculated strictly on unique invoices.

---

## 3. Strategic Analysis & Insights (Analyze Phase)

To ensure data integrity between financial reporting (line items) and logistics tracking (unique invoices), Python (Pandas) was utilized to handle data granularity prior to visual exploration.

```python
# Data Validation in Python: Ensuring logistics metrics count distinct invoices, not duplicate line items
df_orders = df.drop_duplicates(subset=['orderID', 'shipperName', 'freight', 'shipCountry', 'shippingStatus'])
print(f"Total Unique Orders for Logistics Analysis: {len(df_orders)}") 
# Output: 830 (Matching BI exact distinct order count)
```

### Q1: Shipping Performance vs. Freight Cost
<img width="488" height="655" alt="02_Dashboard_Shipper_Cost_vs _Delay_Rate" src="https://github.com/user-attachments/assets/5d413683-fb16-4a49-bf32-bbafccd46f95" />


**Insight:** United Package presents a severe operational inefficiency. Despite charging the highest average freight premium ($105.98 per order), they maintain the highest failure rate, responsible for nearly 50% of all delayed orders (4.91% delay rate). Conversely, Federal Shipping offers the most reliable logistics at a lower cost (3.53% delay rate).
**Recommendation:** Initiate immediate vendor contract renegotiations with United Package. Divert high-priority, high-margin shipping volume to Federal Shipping to optimize delivery SLAs and reduce freight expenditure.

*BigQuery Validation (Distinct Orders):*
```sql
SELECT
  shipperName,
  COUNT(DISTINCT orderID) AS totalOrders,
  COUNT(DISTINCT CASE WHEN shippingStatus = 'Delayed' THEN orderID END) AS delayedOrders,
  ROUND(COUNT(DISTINCT CASE WHEN shippingStatus = 'Delayed' THEN orderID END) / COUNT(DISTINCT orderID) * 100, 2) AS delayPercentage,
  ROUND(AVG(freight), 2) AS avgFreightCost
FROM `northwind-supply-chain.northwind_raw.master_supply_chain_data`
GROUP BY shipperName
ORDER BY delayPercentage DESC;
```

### Q2: Financial Profitability by Category
<img width="800" height="536" alt="03_Dashboard_Revenue_by_Category" src="https://github.com/user-attachments/assets/f4d193a2-a360-44b1-b5c2-d2517a22865f" />


**Insight:** Revenue generation is heavily top-heavy. The top three categories (Beverages, Dairy Products, and Confections) drive over $669,000 in net revenue, accounting for more than 50% of the company's total sales volume. 
**Recommendation:** Implement prioritized safety-stock policies and rigorous inventory forecasting specifically for Beverages and Dairy. Protecting the supply chain for these top-tier categories is critical to maintaining overall corporate cash flow.

### Q3: Global Delay Hotspots
<img width="487" height="542" alt="04_Dashboard_Global_Delay_Hotspots" src="https://github.com/user-attachments/assets/87fc30f6-9a0a-4d65-83bb-9121c5dcc1f2" />


**Insight:** Logistical bottlenecks are highly concentrated geographically. The United States is the primary hotspot for delayed volume, followed closely by key Western European markets (Germany and the UK).
**Recommendation:** Conduct a targeted audit of customs processing and last-mile carrier handoffs in the US and Germany. Investigate the ROI of establishing localized distribution hubs in North America and Western Europe to reduce cross-border transit times.

---

## 4. Executive Action Plan (Act Phase)

1.  **Logistics Restructuring:** Shipping inefficiencies are actively inflating operational costs without improving service. Volume must be immediately shifted away from United Package toward more reliable carriers like Federal Shipping.
2.  **Inventory Prioritization:** Over half of the company's net revenue is reliant on just three product categories. These require ring-fenced inventory management to protect the bottom line from supply chain disruptions.
3.  **Regional Supply Chain Interventions:** Fulfillment delays are highly localized in the USA and Western Europe. Targeted route-level audits are required in these specific geographic corridors.

**Overall Strategic Goal:** By eliminating underperforming shipping vendors and protecting inventory for top-tier products, Northwind Traders can significantly reduce revenue leakage and improve overall margin efficiency.

---

## Repository Structure
- `Dataset/`: Raw CSV files and data dictionary.
- `BigQuery/`: SQL scripts for data cleaning, transformation, and advanced analysis.
- `Python/`: Jupyter Notebook containing EDA, data validation, and Matplotlib/Seaborn visualizations.
- `Tableau/`: Dashboard layout images and public workbook links.
