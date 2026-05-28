create database Adventureworks;
use  Adventureworks;

-- KPI Cards
-- Total Sales
SELECT SUM(SalesAmount) AS Total_Sales FROM Sales;

-- Total Profit
SELECT SUM(Profit) AS Total_Profit
FROM Sales;

-- Total Production Cost
SELECT SUM(ProductionCost) AS Total_ProductionCost
FROM Sales;

-- Total number of orders (rows)
SELECT COUNT(*) AS Total_Orders
FROM Sales;

-- Average sales per order
SELECT AVG(SalesAmt) AS Avg_Sales_per_Order
FROM Sales;

-- 6. Year-wise Sales
SELECT Year,
       SUM(SalesAmt) AS Total_Sales
FROM Sales
GROUP BY Year
ORDER BY Year;

-- 7. Month-wise Sales (Year + Month)
SELECT 
    MonthName,
    SUM(SalesAmt) AS Total_Sales
FROM Sales
GROUP BY MonthNo, MonthName
ORDER BY MonthNo;


-- 8. Quarter-wise Sales
SELECT 
       Quarter,
       SUM(SalesAmt) AS Total_Sales
FROM Sales
GROUP BY Quarter
ORDER BY Quarter;

-- 9. Weekday-wise Sales (which day is strongest?)
SELECT 
    Weekdayname,
    SUM(SalesAmt) AS Total_Sales
FROM Sales
GROUP BY Weekdayname
ORDER BY 
    CASE Weekdayname
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;


-- region wise sales
SELECT 
    dst.SalesTerritoryRegion,
    SUM(s.SalesAmt) AS Total_Sales
FROM Sales s
JOIN dimsalesterritory dst
    ON s.SalesTerritoryKey = dst.SalesTerritoryKey
GROUP BY dst.SalesTerritoryRegion
ORDER BY Total_Sales DESC;

--  Top 10 products by sales
SELECT p.EnglishProductName,
       SUM(s.SalesAmt) AS Total_Sales
FROM Sales s
JOIN DimProduct p
  ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY Total_Sales DESC
LIMIT 10;

-- 14. Product category-wise sales
SELECT p.EnglishProductCategoryname as productname ,
       SUM(s.SalesAmt) AS Total_Sales
FROM Sales s
JOIN DimProduct p
  ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductCategoryname
ORDER BY Total_Sales DESC;

-- 15. Product subcategory-wise profit
SELECT p.EnglishProductSubcategoryName,
       SUM(s.Profit) AS Total_Profit
FROM Sales s
JOIN DimProduct p
  ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductSubcategoryName
ORDER BY Total_Profit DESC;

-- TOTAL SALES FOR YEAR 2013
SELECT 
    Year,
    SUM(SalesAmount) AS Total_Sales
FROM Sales
WHERE Year = 2013
GROUP BY Year;

-- Top 10 products by sales
SELECT 
    p.EnglishProductName as product_name,
    SUM(s.SalesAmt) AS Total_Sales
FROM Sales s
JOIN DimProduct p
  ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY Total_Sales DESC
LIMIT 10;

-- Products sold in one region
SELECT 
    p.EnglishProductName AS ProductName,
    SUM(s.SalesAmt) AS Total_Sales
FROM Sales s
JOIN dimsalesterritory t
    ON s.SalesTerritoryKey = t.SalesTerritoryKey
JOIN DimProduct p
    ON s.ProductKey = p.ProductKey
WHERE t.SalesTerritoryRegion = 'Australia'     
GROUP BY p.EnglishProductName
ORDER BY Total_Sales DESC;

-- best selling product in each year
SELECT 
    s.Year,
    p.EnglishProductName as product_name,
    SUM(s.SalesAmt) AS Total_Sales
FROM Sales s
JOIN DimProduct p
  ON s.ProductKey = p.ProductKey
GROUP BY s.Year, p.EnglishProductName
ORDER BY s.Year, Total_Sales DESC;

-- Rank Products by Sales within each Year
WITH product_year AS (
    SELECT 
        Year,
        p.EnglishProductName as product_name,
        SUM(s.SalesAmt) AS Total_Sales
    FROM Sales s
    JOIN DimProduct p
      ON s.ProductKey = p.ProductKey
    GROUP BY Year, p.EnglishProductName
)
SELECT 
    Year,
    product_name,
    Total_Sales,
    RANK() OVER (PARTITION BY Year ORDER BY Total_Sales DESC) AS Sales_Rank_In_Year
FROM product_year
ORDER BY Year, Sales_Rank_In_Year ASC;

-- top 1 products for each region
WITH region_product AS (
    SELECT 
        t.SalesTerritoryRegion AS Region,      -- region from dimsalesterritory
        p.EnglishProductName AS ProductName,   -- or the exact product-name column
        SUM(s.SalesAmt) AS Total_Sales
    FROM Sales s
    JOIN dimsalesterritory t
        ON s.SalesTerritoryKey = t.SalesTerritoryKey
    JOIN DimProduct p
        ON s.ProductKey = p.ProductKey
    GROUP BY t.SalesTerritoryRegion, p.EnglishProductName
),
ranked AS (
    SELECT 
        Region,
        ProductName,
        Total_Sales,
        ROW_NUMBER() OVER (
            PARTITION BY Region
            ORDER BY Total_Sales DESC
        ) AS rn
    FROM region_product
)
SELECT Region, ProductName, Total_Sales
FROM ranked
WHERE rn <= 1
ORDER BY Region, Total_Sales DESC;






