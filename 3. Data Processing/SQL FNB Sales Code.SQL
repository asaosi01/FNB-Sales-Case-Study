select * from `workspace`.`default`.`sales_case_study` limit 100;

-- convert Data timestamp into date "YYYY-MM-DD"
SELECT 
  to_date(Date) AS Date,
   Sales,
   `Cost Of Sales`,
    `Quantity Sold`
FROM sales_case_study;

-- round values for sales and cost of sales
SELECT 
  to_date(Date) AS Date, 
  ROUND(Sales, 0) AS Sales,
  ROUND(`Cost Of Sales`, 0) AS Cost_Of_Sales,
  `Quantity Sold`
FROM sales_case_study;

-- daily sales price per unit
SELECT 
  to_date(Date) AS Date,
  ROUND(Sales, 0) AS Sales,
  ROUND(`Cost Of Sales`, 0) AS Cost_Of_Sales,
  ROUND((Sales / `Quantity Sold`),2) AS Price_Per_Unit
FROM sales_case_study;

-- average unit sales price of this product
SELECT 
  to_date(Date) AS Date,
  AVG(`Sales` / `Quantity Sold`) AS Avg_Unit_Sales_Price
FROM sales_case_study
GROUP BY to_date(Date);

-- What is the daily % gross profit? 
SELECT
  to_date(Date) AS Date, 
  ROUND(Sales, 0) AS Sales,
  ROUND(((`Sales` - `Cost Of Sales`) / `Sales`) * 100, 2) AS Daily_Gross_Profit_Percent
FROM sales_case_study;

-- Daily % gross profit per unit
SELECT
  to_date(Date) AS Date, 
  ((Sales - `Cost Of Sales`) / `Quantity Sold`) /
    (Sales / `Quantity Sold`) * 100 AS GP_Per_Unit_Percent
FROM sales_case_study;

-- Promotion period
SELECT
    to_date(Date) AS Date,
    ROUND((Sales / `Quantity Sold`),2) AS Price_Per_Unit,
    `Quantity Sold`
FROM sales_case_study
ORDER BY Price_Per_Unit ASC
LIMIT 20;   -- lowest prices = likely promotions

--  Promo Period 1
WITH promo AS (
    SELECT
        AVG(Sales / `Quantity Sold`) AS promo_price,
        AVG(`Quantity Sold`) AS promo_qty
    FROM sales_case_study
    WHERE to_date(Date) BETWEEN '2014-02-10' AND '2014-02-16'
),
normal AS (
    SELECT
        AVG(Sales / `Quantity Sold`) AS normal_price,
        AVG(`Quantity Sold`) AS normal_qty
    FROM sales_case_study
    WHERE to_date(Date) BETWEEN '2014-02-01' AND '2014-02-28'
)
SELECT
    ((promo_qty - normal_qty) / normal_qty) /
    ((promo_price - normal_price) / normal_price) AS Price_Elasticity
FROM promo, normal;

--  Promo Period 2
WITH promo AS (
    SELECT
        AVG(Sales / `Quantity Sold`) AS promo_price,
        AVG(`Quantity Sold`) AS promo_qty
    FROM sales_case_study
    WHERE to_date(Date) BETWEEN '2014-04-01' AND '2014-04-05'
),
normal AS (
    SELECT
        AVG(Sales / `Quantity Sold`) AS normal_price,
        AVG(`Quantity Sold`) AS normal_qty
    FROM sales_case_study
    WHERE to_date(Date) BETWEEN '2014-04-01' AND '2014-04-28'
)
SELECT
    Round(((promo_qty - normal_qty) / normal_qty) /
    ((promo_price - normal_price) / normal_price),2) AS Price_Elasticity
FROM promo, normal;

--  Promo Period 3
WITH promo AS (
    SELECT
        AVG(Sales / `Quantity Sold`) AS promo_price,
        AVG(`Quantity Sold`) AS promo_qty
    FROM sales_case_study
    WHERE to_date(Date) BETWEEN '2014-12-21' AND '2014-12-27'
),
normal AS (
    SELECT
        AVG(Sales / `Quantity Sold`) AS normal_price,
        AVG(`Quantity Sold`) AS normal_qty
    FROM sales_case_study
    WHERE to_date(Date) BETWEEN '2014-12-01' AND '2014-12-31'
)
SELECT
    Round(((promo_qty - normal_qty) / normal_qty) /
    ((promo_price - normal_price) / normal_price),2) AS Price_Elasticity
FROM promo, normal;


--Final Code final_sales_dataset
SELECT
    to_date(Date) AS Date,
    ROUND(Sales,0) AS Sales ,
    `Quantity Sold` AS Quantity_Sold,
    ROUND(`Cost Of Sales`,0) AS Cost_of_Sales,

    -- Core metrics
    ROUND(Sales / `Quantity Sold`,2) AS Price_Per_Unit,
    ROUND(Sales - `Cost Of Sales`,2) AS Gross_Profit,
    ROUND((((Sales - `Cost Of Sales`) / Sales) * 100),2) AS Gross_Profit_Percent,
    ROUND(((Sales - `Cost Of Sales`) / `Quantity Sold`),2) AS GP_Per_Unit,

    -- Time intelligence
    dayofweek(to_date(Date)) AS Day_Of_Week,
    month(to_date(Date)) AS Month,
    year(to_date(Date)) AS Year,

    -- Promo flag (auto-detected)
    CASE
        WHEN Sales / `Quantity Sold` <
             (SELECT AVG(Sales / `Quantity Sold`) * 0.85 FROM sales_case_study)
        THEN 'Promotion'
        ELSE 'Normal'
    END AS Promo_Flag,

    -- Seasonality buckets
    CASE
        WHEN month(to_date(Date)) IN (11,12,1) THEN 'Peak Season'
        WHEN month(to_date(Date)) IN (6,7,8) THEN 'Low Season'
        ELSE 'Mid Season'
    END AS Seasonality_Group
FROM sales_case_study
ORDER BY Date;


