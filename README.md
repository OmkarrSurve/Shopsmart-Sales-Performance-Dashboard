# 🛒 ShopSmart — End-to-End Sales Performance Dashboard

---

## 📌 Project Overview

This is an end-to-end Business Intelligence project simulating the role of a Data Analyst at **ShopSmart Retail Inc.**, a US-based retail company. The project covers the full analyst workflow — from raw data ingestion and SQL analysis to an interactive 5-page Power BI dashboard with dynamic What-If scenario planning.

The dashboard was built to answer a real business brief from the VP of Sales and is designed to mirror actual day-to-day analyst work in a retail or e-commerce organization.

---

### Business Questions Answered

1. Which regions and states are most and least profitable?
2. Which product categories drive revenue vs. which drain profit?
3. Who are our most valuable customers and how are they segmented?
4. What happens to revenue and profit if we grow sales by X%?
5. How is our discount strategy impacting profitability?
6. Which shipping modes are most efficient and cost-effective?

---

## 🗂️ Dataset

**Source:** [Superstore Sales Dataset — Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)

| Property | Detail |
|---|---|
| Rows | ~9,994 |
| Columns | 21 |
| Date Range | January 2014 — December 2017 |
| Geography | United States (4 Regions, 49 States) |
| Categories | Furniture, Office Supplies, Technology |

### Columns in Dataset

| Column | Description |
|---|---|
| Row ID | Unique row identifier |
| Order ID | Unique order identifier |
| Order Date | Date order was placed |
| Ship Date | Date order was shipped |
| Ship Mode | Shipping method selected |
| Customer ID | Unique customer identifier |
| Customer Name | Full name of customer |
| Segment | Customer segment (Consumer, Corporate, Home Office) |
| Country | Country of order |
| City | City of delivery |
| State | State of delivery |
| Postal Code | Delivery postal code |
| Region | US region (East, West, Central, South) |
| Product ID | Unique product identifier |
| Category | Product category |
| Sub-Category | Product sub-category |
| Product Name | Full product name |
| Sales | Revenue from the order item |
| Quantity | Number of units ordered |
| Discount | Discount applied (0–1 scale) |
| Profit | Profit from the order item |

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **Excel** | Initial data exploration and cleaning log |
| **PostgreSQL** | Data storage and SQL analysis |
| **Power Query** | Data transformation and derived columns |
| **Power BI Desktop** | Dashboard development and DAX measures |
| **DAX** | Business metrics and calculated columns |

---

## 🔄 Project Workflow

```
Raw CSV Dataset
      │
      ▼
Excel — Exploration & Cleaning Log
      │
      ▼
PostgreSQL — Table Creation & Data Import
      │
      ▼
SQL Analysis — 11 Business Queries
      │
      ▼
Power Query — Transformations & Derived Columns
      │
      ▼
DAX — Measures & Calculated Columns
      │
      ▼
Power BI — 5-Page Interactive Dashboard
```

---

## 🧹 Data Cleaning Steps

All cleaning was performed in **Power Query** and documented below:

| Step | Action | Reason |
|---|---|---|
| 1 | Changed Order Date type using locale (EN-US) | Dates were in MM/DD/YYYY format, system locale was DD/MM/YYYY |
| 2 | Changed Ship Date type using locale (EN-US) | Same reason as above |
| 3 | Trimmed all text columns | Removed leading and trailing whitespace |
| 4 | Removed duplicate rows | Ensured Row ID uniqueness |
| 5 | Verified no negative Sales values | Profit can be negative but Sales cannot |
| 6 | Added `Delivery Days` column | Derived from Ship Date minus Order Date |
| 7 | Added `Discount Band` column | Grouped discounts into meaningful bands |

### Derived Columns Added

```
Delivery Days  = Duration.Days([Ship Date] - [Order Date])

Discount Band  = if [Discount] = 0 then "No Discount"
                 else if [Discount] <= 0.2 then "Low (1-20%)"
                 else if [Discount] <= 0.4 then "Medium (21-40%)"
                 else "High (40%+)"
```

---

## 🗄️ SQL Analysis

Data was loaded into PostgreSQL and analyzed using the following queries before connecting to Power BI.

### Table Schema

```sql
CREATE TABLE superstore (
    row_id          INT,
    order_id        VARCHAR(25),
    order_date      DATE,
    ship_date       DATE,
    ship_mode       VARCHAR(30),
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    segment         VARCHAR(30),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     VARCHAR(10),
    region          VARCHAR(20),
    product_id      VARCHAR(25),
    category        VARCHAR(30),
    sub_category    VARCHAR(30),
    product_name    VARCHAR(200),
    sales           DECIMAL(10,2),
    quantity        INT,
    discount        DECIMAL(5,2),
    profit          DECIMAL(10,2),
    delivery_days   INT,
    discount_band   VARCHAR(20)
);
```

### Key SQL Queries

**1. Executive KPIs**
```sql
SELECT
    COUNT(DISTINCT order_id)                                    AS total_orders,
    COUNT(DISTINCT customer_id)                                 AS total_customers,
    ROUND(SUM(sales)::NUMERIC, 2)                               AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                              AS total_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)             AS profit_margin_pct,
    ROUND((SUM(sales)/COUNT(DISTINCT order_id))::NUMERIC, 2)    AS avg_order_value
FROM superstore;
```

**2. Monthly Revenue & Profit Trend**
```sql
SELECT
    TO_CHAR(order_date, 'YYYY-MM')          AS month,
    TO_CHAR(order_date, 'Mon YYYY')         AS month_label,
    ROUND(SUM(sales)::NUMERIC, 2)           AS monthly_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS monthly_profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct
FROM superstore
GROUP BY 1, 2
ORDER BY 1;
```

**3. Regional Performance**
```sql
SELECT
    region,
    COUNT(DISTINCT order_id)                AS total_orders,
    COUNT(DISTINCT customer_id)             AS total_customers,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct
FROM superstore
GROUP BY region
ORDER BY revenue DESC;
```

**4. Loss-Making Sub-Categories**
```sql
SELECT
    sub_category,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct
FROM superstore
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY profit ASC;
```

**5. Discount Impact on Profit**
```sql
SELECT
    discount_band,
    COUNT(DISTINCT order_id)                AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2)           AS revenue,
    ROUND(SUM(profit)::NUMERIC, 2)          AS profit,
    ROUND((SUM(profit)/SUM(sales)*100)::NUMERIC, 2)    AS margin_pct
FROM superstore
GROUP BY discount_band
ORDER BY margin_pct DESC;
```

> Full SQL scripts available in the `/sql` folder of this repository

---

## 📊 DAX Measures

All measures are stored in a dedicated `_Measures` table for clean organization.

### Core Measures

```dax
Total Revenue       = SUM(superstore[Sales])
Total Profit        = SUM(superstore[Profit])
Total Orders        = DISTINCTCOUNT(superstore[Order ID])
Total Customers     = DISTINCTCOUNT(superstore[Customer ID])
Total Quantity      = SUM(superstore[Quantity])
Profit Margin %     = DIVIDE([Total Profit], [Total Revenue]) * 100
Avg Order Value     = DIVIDE([Total Revenue], [Total Orders])
Avg Delivery Days   = AVERAGE(superstore[Delivery Days])
```

### Time Intelligence Measures

```dax
YoY Revenue Growth % =
VAR CurrentYear  = [Total Revenue]
VAR PreviousYear = CALCULATE([Total Revenue], SAMEPERIODLASTYEAR('Order Date Table'[Date]))
RETURN DIVIDE(CurrentYear - PreviousYear, PreviousYear) * 100

Running Total Revenue =
CALCULATE([Total Revenue], DATESYTD('Order Date Table'[Date]))
```

### Customer Measures

```dax
Repeat Customers =
SUMX(
    VALUES(superstore[Customer ID]),
    IF(CALCULATE(DISTINCTCOUNT(superstore[Order ID])) > 1, 1, 0)
)

Repeat Customer % = DIVIDE([Repeat Customers], [Total Customers]) * 100

Avg Revenue per Customer = DIVIDE([Total Revenue], [Total Customers])
```

### What-If Measures

```dax
Projected Revenue       = [Total Revenue] * (1 + 'Growth Slider'[Growth Slider Value] / 100)
Projected Profit        = [Total Profit]  * (1 + 'Growth Slider'[Growth Slider Value] / 100)
Revenue Uplift          = [Projected Revenue] - [Total Revenue]
Profit Uplift           = [Projected Profit]  - [Total Profit]
Projected Profit Margin % = DIVIDE([Projected Profit], [Projected Revenue]) * 100
```

### RFM Calculated Column

```dax
RFM Segment =
VAR freq =
    CALCULATE(DISTINCTCOUNT(superstore[Order ID]), ALLEXCEPT(superstore, superstore[Customer ID]))
VAR monetary =
    CALCULATE(SUM(superstore[Sales]), ALLEXCEPT(superstore, superstore[Customer ID]))
VAR recency =
    DATEDIFF(
        CALCULATE(MAX(superstore[Order Date]), ALLEXCEPT(superstore, superstore[Customer ID])),
        DATE(2017, 12, 31), DAY
    )
RETURN
IF(freq >= 5 && monetary >= 5000 && recency <= 100, "Champions",
IF(freq >= 3 && monetary >= 2000 && recency <= 200, "Loyal Customers",
IF(freq >= 2 && monetary >= 1000 && recency <= 300, "Potential Loyalists",
IF(recency > 300, "At Risk", "New Customers"))))
```

---

## 📄 Dashboard Pages

### Page 1 — Executive Overview
**Audience:** CEO, VP of Sales

Visuals included:
- 6 KPI cards — Total Revenue, Total Profit, Total Orders, Profit Margin %, Avg Order Value, YoY Growth %
- Monthly Revenue & Profit trend line chart
- Revenue by Customer Segment donut chart
- Quarterly Revenue by Year clustered bar chart
- Top 5 States by Revenue bar chart
- Slicers — Year, Region, Segment

---

### Page 2 — Regional Performance
**Audience:** Sales Manager, Regional Heads

Visuals included:
- 4 region-specific KPI cards (North, South, East, West)
- US Filled Map colored by profit margin, total revenue, total orders
- Revenue vs Profit by Region clustered bar chart
- Profit Margin % by Region with conditional formatting
- Avg Delivery Days by Region & Ship Mode matrix
- Drill-through to Region Detail page

---

### Page 3 — Product Analysis
**Audience:** Category Manager, Merchandising Team

Visuals included:
- 5 KPI cards — Total Products, Total Quantity, Profit Margin %, Total Categories, Avg Discount %
- Revenue & Profit by Category clustered bar chart
- Profit by Sub-Category bar chart with red/green conditional formatting
- Discount vs Profit scatter plot with trend line and danger zone constant line
- Top 10 Products by Revenue with Top N filter
- Category drill-down hierarchy

---

### Page 4 — Customer Insights
**Audience:** Marketing Team, CRM Manager

Visuals included:
- 5 KPI cards — Total Customers, Avg Revenue per Customer, Avg Orders per Customer, Top Segment, Repeat Customer %
- Revenue by Segment & Year line chart with trend lines
- Customer Count by Segment donut chart
- Top 10 Most Profitable Customers bar chart
- RFM Segment summary matrix (Frequency, Monetary, Recency, Revenue per segment)

---

### Page 5 — What-If Growth Simulator
**Audience:** Leadership, Strategy Team

Visuals included:
- 2 dynamic sliders — Sales Growth % (0–50%) and Discount Reduction % (0–30%)
- 4 KPI cards — Total Revenue, Projected Revenue, Revenue Uplift, Projected Profit, Project Profit Margin%
- Actual vs Projected Revenue by Year clustered bar chart
- Projected Revenue by Category bar chart
- Actual vs Projected Profit by Year clustered bar chart
  

---

## 💡 Key Business Insights

1. **Technology drives the highest revenue** but Furniture has the worst profit margin — a critical finding for category strategy

2. **Tables and Bookcases are loss-making sub-categories** — every sale costs the company profit. Recommend reviewing vendor costs or discontinuing low-margin SKUs

3. **Discounts above 20% consistently generate negative profit** — the current discount policy needs immediate review. High discount band shows negative overall margin

4. **The West region generates the highest revenue** but Central has the best profit margin — sales volume alone does not indicate profitability

5. **Consumer segment drives the highest revenue** but Corporate customers deliver better profit per order — marketing spend should be rebalanced

6. **At Risk customers** (no purchase in 300+ days) represent a significant revenue recovery opportunity through targeted win-back campaigns

7. **A 10% sales growth target** translates to approximately $230K additional revenue based on the 2017 baseline — giving leadership a concrete number to plan against

---

## 📁 Repository Structure

```
shopsmart-dashboard/
│
├── data/
│   ├── superstore_raw.csv           ← Original Kaggle dataset
│   └── superstore_cleaned.csv       ← Cleaned dataset used in Power BI
│
├── sql/
│   └── Sqlsales.sql    ← Entire Sql schema along with all the queries
│
├── powerbi/
│   └── shopsmart_dashboard.pbix     ← Power BI dashboard file
│
└── README.md
```

---

## 🚀 How to Run This Project

### Prerequisites
- PostgreSQL 18
- Power BI Desktop (free)

## 📌 Skills Demonstrated

| Skill | Where Used |
|---|---|
| SQL — Joins, Aggregations, CTEs, Window Functions | PostgreSQL analysis queries |
| Data Cleaning & Transformation | Power Query, Excel |
| DAX — Measures, Calculated Columns, Time Intelligence | All 5 dashboard pages |
| Data Modeling — Relationships, Date Tables | Power BI model view |
| Business Intelligence — KPIs, Trend Analysis | Executive Overview page |
| RFM Customer Segmentation | Customer Insights page |
| What-If Scenario Planning | Growth Simulator page |
| Data Storytelling | Insights and recommendations |
| Conditional Formatting | Regional and Product pages |
| Drill-Through Navigation | Region Detail page |

---


## 📃 License

This project is open source and available under the [MIT License](LICENSE).

---

*Dataset sourced from Kaggle — Superstore Sales Dataset. Used for portfolio and educational purposes only.*
