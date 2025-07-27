-- creating database
create database sales;
use sales;

-- creating tables
create table customers(customer_code varchar(50) , customer_name varchar(255), customer_type varchar(50));
create table products(product_code varchar(50), product_type varchar(100));
create table markets(markets_code varchar(50), markets_name varchar(100), zone varchar(50));
create table transactions(product_code varchar(50), customer_code varchar(50), market_code varchar(50), order_date date, sales_qty int(255), sales_amount int(255), currency varchar(30));
create table dates(date varchar(50), cy_date varchar(50), year int, month_name varchar(50), date_yy_mm varchar(50));

-- Adding primary keys
ALTER TABLE customers ADD PRIMARY KEY (customer_code);
ALTER TABLE products ADD PRIMARY KEY (product_code);
ALTER TABLE markets ADD PRIMARY KEY (markets_code);

-- Adding foreign key
ALTER TABLE transactions
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_code)
REFERENCES customers(customer_code);

ALTER TABLE transactions
ADD CONSTRAINT fk_product
FOREIGN KEY (product_code)
REFERENCES products(product_code);

ALTER TABLE transactions
ADD CONSTRAINT fk_market
FOREIGN KEY (market_code)
REFERENCES markets(markets_code);


select * from customers;
select * from products;
select * from markets;
select * from transactions;
select * from dates;

-- DATA CLEANING

-- Temporarily Disable Safe Update Mode
SET SQL_SAFE_UPDATES = 0;

-- 1.Removing the zones with null values. These zones are of markets based outside India.
DELETE FROM markets
WHERE zone = '';

-- 2.Handling Negative Sales Amounts
DELETE FROM transactions where sales_amount <=0;

 -- 3.Standardizing Currency 
select * from transactions
where currency = 'usd';

update transactions 
set sales_amount = sales_amount * 85
where currency = 'usd';

update transactions 
set currency = 'INR'
where currency = 'usd';

-- 4.converting string to proper DATE format
ALTER TABLE transactions
ADD formatted_order_date DATE;

UPDATE transactions
SET formatted_order_date = STR_TO_DATE(order_date, '%d-%m-%Y');


-- 5.checks whether the product code from transaction table does exist in its respective master table- products ,to avoid inconsistencies 
SELECT DISTINCT product_code
FROM transactions
WHERE product_code NOT IN (SELECT product_code FROM products);

-- 6.checks whether the customer code from transaction table does exist in its respective master table- customers ,to avoid inconsistencies 
SELECT DISTINCT customer_code
FROM transactions
WHERE customer_code NOT IN (SELECT customer_code FROM customers);

-- 7.checks whether the market code from transaction table does exist in its respective master table- markets ,to avoid inconsistencies 
SELECT DISTINCT market_code
FROM transactions
WHERE market_code NOT IN (SELECT market_code FROM markets);


-- ADDINNG 2 NEW COLUMNS 'PROFITS'  AND 'COST' TO TABLE TRANSACTIONS CONSIDERING COST IS 70% OF THE SALES

ALTER TABLE transactions
ADD COLUMN cost DECIMAL(10,2),
ADD COLUMN profit DECIMAL(10,2);

UPDATE transactions
SET 
    cost = sales_amount * 0.7,
    profit = sales_amount * 0.3;


-- SQL QUERIES FOR BUSINESS INSIGHTS

 -- 1.Total Revenue
SELECT SUM(sales_amount) AS total_revenue
FROM transactions;

-- 2.Total Sales
SELECT SUM(sales_qty) AS total_sales
FROM transactions;

-- 3.Total Profit gained
SELECT SUM(profit) AS total_profit
FROM transactions;

-- 4.Top 5 Customers by Revenue
SELECT c.customer_name, SUM(t.sales_amount) AS total_revenue
FROM transactions t
JOIN customers c ON t.customer_code = c.customer_code
GROUP BY c.customer_name
ORDER BY total_revenue DESC
LIMIT 5;

-- 5.Top 5 Products by Profits
SELECT p.product_code, SUM(t.profit) AS total_profit
FROM transactions t
JOIN products p ON t.product_code = p.product_code
GROUP BY p.product_code
ORDER BY total_profit DESC
LIMIT 5;

-- 6.Market-wise Sales Performance
SELECT 
    m.markets_name,
    SUM(t.sales_qty) AS total_sales_qty,
    SUM(t.sales_amount) AS total_revenue,
    SUM(t.profit) AS total_profit
FROM transactions t
JOIN markets m ON t.market_code = m.markets_code
GROUP BY m.markets_name
ORDER BY total_revenue DESC;

-- 7.Monthly Sales and Profit Over Time
SELECT 
    DATE_FORMAT(STR_TO_DATE(order_date, '%d-%m-%Y'), '%Y-%m') AS month,
    SUM(sales_amount) AS monthly_sales,
    SUM(profit) AS monthly_profit
FROM transactions
GROUP BY month
ORDER BY month;

-- 8.Sales Trend Over Time (Yearly)
SELECT 
    DATE_FORMAT(STR_TO_DATE(order_date, '%d-%m-%Y'), '%Y') AS year,
    SUM(sales_amount) AS yearly_sales,
    SUM(profit) AS yearly_profit
FROM transactions
GROUP BY year
ORDER BY year;

-- 9.Top 3 Profitable Months
SELECT 
    DATE_FORMAT(formatted_order_date, '%Y-%m') AS month,
    SUM(profit) AS total_profit
FROM transactions
GROUP BY month
ORDER BY total_profit DESC
LIMIT 3;

-- 10.3 Least performing months based on Sales
SELECT 
    DATE_FORMAT(formatted_order_date, '%Y-%m') AS month,
    SUM(sales_qty) AS sales_qty,
    SUM(sales_amount) AS total_revenue
FROM transactions
GROUP BY month
ORDER BY total_revenue DESC
LIMIT 3;

