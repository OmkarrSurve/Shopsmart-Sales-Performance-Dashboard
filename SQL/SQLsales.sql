
CREATE DATABASE shopmart;

CREATE TABLE superstore2(
Row_ID	INT	PRIMARY KEY	NOT NULL,
Order_ID	VARCHAR(20)		NOT NULL,
Order_Date	DATE		NOT NULL,
Ship_Date	DATE 		NOT NULL,
Ship_Mode	VARCHAR(20),
Customer_ID	VARCHAR(20)		NOT NULL,
Customer_Name	VARCHAR(40)		NOT NULL,
Segment	VARCHAR(20),		
Country	VARCHAR(20),	
City	VARCHAR(20),	
State	VARCHAR(20),		
Postal_Code	INT		NOT NULL,
Region	VARCHAR(20),	
Product_ID	VARCHAR(20)		NOT NULL,
Category	VARCHAR(20),	
Sub_Category	VARCHAR(20),	
Product_Name	VARCHAR(20),	
Sales	REAL,		
Quantity	INT,	
Discount	REAL,		
Profit	REAL,	
Delivery_Days	INT,		
Discount_Category	VARCHAR(20)		
);

SELECT * FROM superstore2;

ALTER TABLE superstore2
ALTER COLUMN Product_Name TYPE VARCHAR(300);

COPY superstore2(Row_ID,	Order_ID,	Order_Date,	Ship_Date,	Ship_Mode,	Customer_ID,	Customer_Name,	Segment,	Country,	City,	State,	Postal_Code,	Region,	Product_ID,	Category,	Sub_Category,	Product_Name,	Sales,	Quantity,	Discount,	Profit,	Delivery_Days,	Discount_Category)
FROM 'C:\Users\surve\Desktop\PowerBi\superstore.csv'
DELIMITER ','
CSV HEADER
ENCODING 'WIN1252';

-- KPIs
SELECT
    COUNT(DISTINCT order_id)    AS total_orders,
    COUNT(DISTINCT customer_id)  AS total_customers,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND((SUM(sales)/COUNT(DISTINCT order_id))::NUMERIC, 2)AS avg_order_value
FROM superstore2;

--MONTHLY REVENUE & PROFIT TREND

SELECT
    TO_CHAR(order_date, 'YYYY-MM')          AS month,
    TO_CHAR(order_date, 'Mon YYYY')         AS month_label,
    ROUND(SUM(sales)::NUMERIC, 2)           AS monthly_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS monthly_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct
FROM superstore2
GROUP BY 1, 2
ORDER BY 1;

--YEARLY GROWTH

SELECT
    EXTRACT(YEAR FROM order_date)           AS year,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct
FROM superstore2
GROUP BY 1
ORDER BY 1;


-- REGIONAL PERFORMANCE
SELECT
    region,
    COUNT(DISTINCT order_id)                AS total_orders,
    COUNT(DISTINCT customer_id)             AS total_customers,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct
FROM superstore2
GROUP BY region
ORDER BY revenue DESC;

-- STATE LEVEL PERFORMANCE
SELECT
    state,
    region,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct
FROM superstore2
GROUP BY state, region
ORDER BY profit ASC;

-- CATEGORY & SUB-CATEGORY PERFORMANCE
SELECT
    category,
    sub_category,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct,
    SUM(quantity)                           AS units_sold
FROM superstore2
GROUP BY category, sub_category
ORDER BY profit DESC;

-- LOSS-MAKING SUB-CATEGORIES
SELECT
    sub_category,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct
FROM superstore2
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY profit ASC;

-- CUSTOMER SEGMENT ANALYSIS
SELECT
    segment,
    COUNT(DISTINCT customer_id)             AS total_customers,
    COUNT(DISTINCT order_id)                AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit,
    ROUND(AVG(sales)::NUMERIC, 2)           AS avg_order_value
FROM superstore2
GROUP BY segment
ORDER BY revenue DESC;

--  TOP 10 CUSTOMERS BY PROFIT
SELECT
    customer_name,
    segment,
    region,
    COUNT(DISTINCT order_id)                AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit
FROM superstore2
GROUP BY customer_name, segment, region
ORDER BY profit DESC
LIMIT 10;


-- SHIPPING MODE ANALYSIS
SELECT
    ship_mode,
    COUNT(DISTINCT order_id)                AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(AVG(delivery_days)::NUMERIC, 1)   AS avg_delivery_days,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit
FROM superstore2
GROUP BY ship_mode
ORDER BY total_orders DESC;



-- DISCOUNT IMPACT ON PROFIT

SELECT
    discount_category,
    COUNT(DISTINCT order_id)                AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct
FROM superstore2
GROUP BY discount_category
ORDER BY margin_pct DESC;

