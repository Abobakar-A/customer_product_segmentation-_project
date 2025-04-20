CREATE DATABASE IF NOT  EXISTS  SalesDataWlmart;
CREATE TABLE IF NOT EXISTS sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10)  NOT NULL ,
product_line VARCHAR(10) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(6,4) NOT NULL,
total DECIMAL(12,4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pect  FLOAT(11,9),
gross_income DECIMAL(12,4),
rating FLOAT(3,1)
);

ALTER TABLE sales MODIFY COLUMN product_line VARCHAR(50) NOT NULL;
ALTER TABLE sales MODIFY COLUMN rating FLOAT NOT NULL;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\salesdatawlmart\\WalmartSalesData.csv.csv'
INTO TABLE sales
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT*
FROM sales;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------Feature Engineering------------------------------------------------------------------------------------------
-- time_of_day
SELECT
time,
(CASE WHEN time BETWEEN '00:00:00'   AND'12:00:00' THEN 'Morning'
WHEN time BETWEEN '12:01:00'   AND'16:00:00' THEN 'Afternoon'
ELSE 'Evening'
END) as time_of_day
FROM sales;

UPDATE sales
set time_of_day=(CASE WHEN time BETWEEN '00:00:00'   AND'12:00:00' THEN 'Morning'
WHEN time BETWEEN '12:01:00'   AND'16:00:00' THEN 'Afternoon'
ELSE 'Evening'
END);

-- day name
SELECT date,
DAYNAME(date) day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales
SET day_name=DAYNAME(date) ;

-- month name
SELECT date,
MONTNAME(date) month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales
SET month_name=MONTHNAME(date) ;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------Generic------------------------------------------------------------------------------------------
-- How many unique cities does wlamart has ?
SELECT 
DISTINCT city
FROM sales;
-- How many unique branch  does wlamart has ?

SELECT 
DISTINCT branch
FROM sales;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------Product----------------------------------------------------------------------------------------------
-- How many unique product lines does walmart has ?
SELECT
count(DISTINCT product_line)
From sales;
-- --------------------------------------------------------------------------------------
-- what is common payment method ?
SELECT
payment_method,
COUNT(payment_method) cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt desc;
-- -------------------------------------------------------------------------------------
-- -- what is most selling  product line ?
SELECT
product_line,
COUNT(product_line) cnt
FROM sales
GROUP BY product_line
ORDER BY cnt desc;
-- ------------------------------------------------------------------------------------
-- what is the total revenu by month ?
SELECT
month_name,
SUM(total) total_revenu
FROM sales
GROUP BY month_name 
ORDER BY total_revenu  DESC;
-- ---------------------------------------------------------------------------------------
-- what is the month had the largest COGS ?
SELECT
month_name,
SUM(cogs) cogs_month
FROM sales
GROUP BY month_name 
ORDER BY cogs_month DESC;
-- -------------------------------------------------------------------------------------
-- whaat product line had the largest revenu?
SELECT
product_line,
SUM(total)  total_revenu_pl
FROM sales
GROUP BY product_line
ORDER BY total_revenu_pl DESC;
-- --------------------------------------------------------------------------------------
-- which city with the largest amoutn of revenu ?
SELECT
city,
branch,
SUM(total)  total_revenu_city
FROM sales
GROUP BY city,branch
ORDER BY total_revenu_city DESC;

-- ----------------------------------------------------------------------------------------
-- what product line has the largest VAT?
SELECT
product_line,
avg(VAT)  VAT_avg
FROM sales
GROUP BY product_line
ORDER BY  VAT_avg  DESC;
-- ---------------------------------------------------------------------------------------
-- which branch sold more products than average product sold ?
SELECT
branch,
sum(quantity)
FROM  sales
GROUP BY branch
HAVING SUM(quantity)  >(
SELECT
avg(quantity)
FROM  sales
);

-- --------------------------------------------------------------------------------------
-- what is the most product line by gender 
SELECT
gender,
product_line,
COUNT(gender) as total_cnt
FROM 
sales 
GROUP BY gender,product_line
ORDER BY total_cnt; 
-- -------------------------------------------------------------------------------------
-- what is the average rating of each oroduct line ?
SELECT
product_line,
avg(rating)
FROM sales
GROUP BY
product_line
ORDER BY
avg(rating) DESC;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------Sales--------------------------------------------------------------------------------------------------
-- Number of sales made in each time of the day per week ?

SELECT
time_of_day,
day_name,
COUNT(*)  total_sales
FROM sales
GROUP BY  time_of_day,day_name
ORDER BY total_sales DESC;
-- --------------------------------------------------------
-- which type of customers bring most of the revenue ?
SELECT
customer_type,
sum(total)
FROM sales
GROUP BY customer_type;
-- -----------------------------------------------------------------------------------
-- which city has the largest tax percent?

SELECT 
city,
avg(VAT) VAT 
FROM
sales
GROUP BY city
ORDER BY  VAT DESC;
-- ---------------------------------------------------------------------------------------------------
-- which customer type pays the most in VAT ?

SELECT 
customer_type,
avg(VAT) VAT 
FROM
sales
GROUP BY customer_type
ORDER BY  VAT DESC;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------Customers--------------------------------------------------------------------------------------
-- how many unique customer type the dada has?
SELECT
DISTINCT customer_type
FROM sales ;
-- ---------------------------------------------------------------------
-- how many uniqe payment type we have ?
SELECT
DISTINCT  payment_method
FROM sales ;
-- --------------------------------------------------------------------
-- which time of the day customers give most rating ?
SELECT
time_of_day,
avg(rating) avg_rating
FROM sales 
GROUP BY time_of_day
ORDER BY avg_rating  DESC;






















