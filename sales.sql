create database sales;
use sales;
create table customers(customer_code varchar(50) , customer_name varchar(255), customer_type varchar(50));
create table products(product_code varchar(50), product_type varchar(100));
create table markets(markets_code varchar(50), markets_name varchar(100), zone varchar(50));
create table transactions(product_code varchar(50), customer_code varchar(50), market_code varchar(50), order_date date, sales_qty int(255), sales_amount int(255), currency varchar(30));
create table dates(date varchar(50), cy_date varchar(50), year int, month_name varchar(50), date_yy_mm varchar(50));

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

-- 2.Deleting sales amount = 0 or -1.
DELETE FROM transactions where sales_amount <=0;



