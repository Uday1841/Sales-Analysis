
-- ============================================================
-- FILE: 02_clean_and_analyze.sql
-- PROJECT: Sales Analysis
-- PURPOSE: Import CSV files, prepare clean data, run 14 analyses
-- DATABASE: MySQL Workbench 8.0+
-- CSV FOLDER: E:/Sales_Analysis/
-- ============================================================

CREATE DATABASE IF NOT EXISTS sales_analysis;
USE sales_analysis;

-- ============================================================
-- PART 1: RESET AND CREATE IMPORT TABLES
-- ============================================================

DROP TABLE IF EXISTS sales_clean;
DROP TABLE IF EXISTS sales_raw;
DROP TABLE IF EXISTS sales_import_stage;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_name VARCHAR(150),
    city VARCHAR(100)
);

CREATE TABLE products (
    product_id VARCHAR(50),
    product_name VARCHAR(150),
    category VARCHAR(100),
    margin_pct VARCHAR(50)
);

-- Import the sales CSV as text first so numeric conversions
-- and date conversions can be handled safely afterwards.

CREATE TABLE sales_import_stage (
    order_id VARCHAR(50),
    order_date VARCHAR(100),
    ship_date VARCHAR(100),
    customer_id VARCHAR(50),
    customer_name VARCHAR(150),
    segment VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100),
    product_id VARCHAR(50),
    product_name VARCHAR(150),
    category VARCHAR(100),
    quantity VARCHAR(50),
    unit_price VARCHAR(50),
    discount_pct VARCHAR(50),
    sales_fix VARCHAR(50),
    profit VARCHAR(50),
    sales_rep VARCHAR(100),
    channel VARCHAR(100),
    payment_method VARCHAR(100),
    year_value VARCHAR(20),
    month_num VARCHAR(20),
    month_name VARCHAR(30),
    quarter VARCHAR(20),
    year_month_text VARCHAR(100),
    delivery_days VARCHAR(30),
    profit_margin_pct VARCHAR(30)
);

-- ============================================================
-- PART 2: IMPORT THE THREE CSV FILES
-- Enable LOCAL INFILE in the MySQL connection if required.
-- ============================================================

LOAD DATA LOCAL INFILE 'E:/Sales_Analysis/customers.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(customer_id, customer_name, city);

LOAD DATA LOCAL INFILE 'E:/Sales_Analysis/products.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(product_id, product_name, category, margin_pct);

-- sales_clean.csv contains the cleaned columns visible in Power BI.
-- The column order here must match the actual CSV file.

LOAD DATA LOCAL INFILE 'E:/Sales_Analysis/sales_clean.csv'
INTO TABLE sales_import_stage
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    order_id,
    order_date,
    ship_date,
    customer_id,
    customer_name,
    segment,
    region,
    city,
    product_id,
    product_name,
    category,
    quantity,
    unit_price,
    discount_pct,
    sales_fix,
    profit,
    sales_rep,
    channel,
    payment_method,
    year_value,
    month_num,
    month_name,
    quarter,
    year_month_text,
    delivery_days,
    profit_margin_pct
);

-- ============================================================
-- PART 3: VERIFY IMPORTS
-- ============================================================

SELECT 'Customers' AS table_name, COUNT(*) AS total_rows
FROM customers;

SELECT 'Products' AS table_name, COUNT(*) AS total_rows
FROM products;

SELECT 'Sales import' AS table_name, COUNT(*) AS total_rows
FROM sales_import_stage;

-- Inspect the imported values before conversion.
SELECT *
FROM sales_import_stage
LIMIT 10;

-- ============================================================
-- PART 4: CREATE THE ANALYSIS TABLE
-- Supports multiple date formats, including DD-MM-YYYY.
-- ============================================================

CREATE TABLE sales_clean AS
SELECT
    TRIM(order_id) AS order_id,

    CASE
        WHEN TRIM(order_date) REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
            THEN STR_TO_DATE(TRIM(order_date), '%d-%m-%Y')
        WHEN TRIM(order_date) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN STR_TO_DATE(TRIM(order_date), '%d/%m/%Y')
        WHEN TRIM(order_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(TRIM(order_date), '%Y-%m-%d')
        WHEN TRIM(order_date) REGEXP '^[0-9]{2} [A-Za-z]+ [0-9]{4}$'
            THEN STR_TO_DATE(TRIM(order_date), '%d %M %Y')
        ELSE NULL
    END AS order_date,

    CASE
        WHEN TRIM(ship_date) REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
            THEN STR_TO_DATE(TRIM(ship_date), '%d-%m-%Y')
        WHEN TRIM(ship_date) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN STR_TO_DATE(TRIM(ship_date), '%d/%m/%Y')
        WHEN TRIM(ship_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(TRIM(ship_date), '%Y-%m-%d')
        WHEN TRIM(ship_date) REGEXP '^[0-9]{2} [A-Za-z]+ [0-9]{4}$'
            THEN STR_TO_DATE(TRIM(ship_date), '%d %M %Y')
        ELSE NULL
    END AS ship_date,

    TRIM(customer_id) AS customer_id,
    TRIM(customer_name) AS customer_name,
    TRIM(segment) AS segment,
    TRIM(region) AS region,
    NULLIF(TRIM(city), '') AS city,
    TRIM(product_id) AS product_id,
    TRIM(product_name) AS product_name,
    TRIM(category) AS category,

    CAST(NULLIF(TRIM(quantity), '') AS DECIMAL(12,2))
        AS quantity,

    CAST(
        NULLIF(REPLACE(TRIM(unit_price), ',', ''), '')
        AS DECIMAL(14,2)
    ) AS unit_price,

    CAST(
        NULLIF(REPLACE(REPLACE(TRIM(discount_pct), '%', ''), ',', ''), '')
        AS DECIMAL(8,2)
    ) AS discount_pct,

    CAST(
        NULLIF(REPLACE(TRIM(sales_fix), ',', ''), '')
        AS DECIMAL(16,2)
    ) AS sales,

    CAST(
        NULLIF(REPLACE(TRIM(profit), ',', ''), '')
        AS DECIMAL(16,2)
    ) AS profit,

    COALESCE(NULLIF(TRIM(sales_rep), ''), 'Unassigned')
        AS sales_rep,

    TRIM(channel) AS channel,
    TRIM(payment_method) AS payment_method,

    CAST(NULLIF(TRIM(year_value), '') AS UNSIGNED)
        AS order_year,

    CAST(NULLIF(TRIM(month_num), '') AS UNSIGNED)
        AS month_num,

    TRIM(month_name) AS month,
    TRIM(quarter) AS quarter_label,

    DATE_FORMAT(
        CASE
            WHEN TRIM(order_date) REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
                THEN STR_TO_DATE(TRIM(order_date), '%d-%m-%Y')
            WHEN TRIM(order_date) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
                THEN STR_TO_DATE(TRIM(order_date), '%d/%m/%Y')
            WHEN TRIM(order_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
                THEN STR_TO_DATE(TRIM(order_date), '%Y-%m-%d')
            WHEN TRIM(order_date) REGEXP '^[0-9]{2} [A-Za-z]+ [0-9]{4}$'
                THEN STR_TO_DATE(TRIM(order_date), '%d %M %Y')
            ELSE NULL
        END,
        '%Y-%m'
    ) AS year_month_label,

    CAST(NULLIF(TRIM(delivery_days), '') AS SIGNED)
        AS delivery_days,

    CAST(
        NULLIF(REPLACE(TRIM(profit_margin_pct), '%', ''), '')
        AS DECIMAL(10,2)
    ) AS profit_margin_pct

FROM sales_import_stage;
-- ============================================================
-- PART 5: DATA QUALITY CHECKS
-- ============================================================

-- Row count and unique order count
SELECT
    COUNT(*) AS rows_after_import,
    COUNT(DISTINCT order_id) AS unique_orders
FROM sales_clean;

-- Total sales and profit
SELECT
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM sales_clean;

-- Region check
SELECT region, COUNT(*) AS orders
FROM sales_clean
GROUP BY region
ORDER BY region;

-- Category check
SELECT category, COUNT(*) AS orders
FROM sales_clean
GROUP BY category
ORDER BY category;

-- Missing cities
SELECT COUNT(*) AS blank_cities
FROM sales_clean
WHERE city IS NULL OR TRIM(city) = '';

-- Unreadable dates
SELECT COUNT(*) AS unreadable_dates
FROM sales_clean
WHERE order_date IS NULL;

-- Negative delivery durations
SELECT COUNT(*) AS negative_delivery
FROM sales_clean
WHERE delivery_days < 0;

-- Missing numeric values
SELECT
    SUM(sales IS NULL) AS missing_sales,
    SUM(profit IS NULL) AS missing_profit,
    SUM(quantity IS NULL) AS missing_quantity
FROM sales_clean;

-- ============================================================
-- PART 6: BUSINESS ANALYSIS — 14 QUESTIONS
-- ============================================================

-- Q1. Headline numbers
SELECT
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    COUNT(DISTINCT order_id) AS orders,
    SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0)
        AS average_order_value,
    SUM(profit) * 100 / NULLIF(SUM(sales), 0)
        AS profit_margin_pct
FROM sales_clean;

-- Q2. Monthly sales and profit
SELECT
    year_month_label AS month,
    SUM(sales) AS sales,
    SUM(profit) AS profit
FROM sales_clean
GROUP BY year_month_label
ORDER BY year_month_label;

-- Q3. Year-over-year sales change
WITH yearly AS (
    SELECT
        order_year,
        SUM(sales) AS sales,
        COUNT(*) AS orders
    FROM sales_clean
    GROUP BY order_year
)
SELECT
    order_year,
    sales,
    orders,
    (
        sales - LAG(sales) OVER (ORDER BY order_year)
    ) * 100 /
    NULLIF(LAG(sales) OVER (ORDER BY order_year), 0)
        AS change_vs_previous_year_pct
FROM yearly
ORDER BY order_year;

-- Q4. Compare sales in 2024 and 2025 by month
SELECT
    month_num,
    SUM(CASE WHEN order_year = 2024 THEN sales END)
        AS sales_2024,
    SUM(CASE WHEN order_year = 2025 THEN sales END)
        AS sales_2025
FROM sales_clean
GROUP BY month_num
ORDER BY month_num;

-- Q5. Category sales and profit margin
SELECT
    category,
    SUM(sales) AS sales,
    SUM(sales) * 100 /
        NULLIF((SELECT SUM(sales) FROM sales_clean), 0)
        AS share_of_sales_pct,
    SUM(profit) * 100 / NULLIF(SUM(sales), 0)
        AS margin_pct
FROM sales_clean
GROUP BY category
ORDER BY sales DESC;

-- Q6. Top 5 products by sales
SELECT
    product_name,
    SUM(sales) AS sales,
    SUM(quantity) AS units_sold
FROM sales_clean
GROUP BY product_name
ORDER BY sales DESC
LIMIT 5;

-- Q7. Best cities in each region
SELECT
    region,
    city,
    SUM(sales) AS sales,
    RANK() OVER (
        PARTITION BY region
        ORDER BY SUM(sales) DESC
    ) AS rank_in_region
FROM sales_clean
GROUP BY region, city
ORDER BY region, rank_in_region;

-- Q8. Discount and profit margin
SELECT
    discount_pct,
    COUNT(*) AS orders,
    SUM(sales) AS sales,
    SUM(profit) * 100 / NULLIF(SUM(sales), 0)
        AS margin_pct
FROM sales_clean
GROUP BY discount_pct
ORDER BY discount_pct;

-- Q9. Top 10 customers
SELECT
    customer_name,
    SUM(sales) AS sales,
    SUM(sales) * 100 /
        NULLIF((SELECT SUM(sales) FROM sales_clean), 0)
        AS share_of_sales_pct
FROM sales_clean
GROUP BY customer_name
ORDER BY sales DESC
LIMIT 10;

-- Q10. Sales representative rankings
SELECT
    sales_rep,
    SUM(sales) AS sales,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS rank_no
FROM sales_clean
GROUP BY sales_rep
ORDER BY rank_no;

-- Q11. Channel and payment method combinations
SELECT
    channel,
    payment_method,
    COUNT(*) AS orders
FROM sales_clean
GROUP BY channel, payment_method
ORDER BY channel, orders DESC;

-- Q12. Average shipping time by region
SELECT
    region,
    AVG(delivery_days) AS average_days
FROM sales_clean
WHERE delivery_days IS NOT NULL
GROUP BY region
ORDER BY region;

-- Q13. Running total of sales
SELECT
    year_month_label AS month,
    SUM(sales) AS monthly_sales,
    SUM(SUM(sales)) OVER (
        ORDER BY year_month_label
    ) AS running_total
FROM sales_clean
GROUP BY year_month_label
ORDER BY year_month_label;

-- Q14. Orders with profit margins above 60%
SELECT
    order_id,
    sales,
    profit,
    profit_margin_pct
FROM sales_clean
WHERE profit_margin_pct > 60
ORDER BY profit_margin_pct DESC;

-- ============================================================
-- END OF SALES ANALYSIS SCRIPT
-- ============================================================
