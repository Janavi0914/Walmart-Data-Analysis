CREATE DATABASE WalmartSalesData;

CREATE TABLE sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1)
);

-- -----------------------Data cleaning------------------------
SELECT * 
FROM sales;

-- -----------------------Feature Engineering-------------------
-- Add time_of_day column

SELECT time,
(CASE
	WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
    WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
    ELSE "Evening"
  END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
	END
  );

-- Add day_name column

SELECT date, dayname(date)
from sales;

ALTER TABLE sales ADD column day_name VARCHAR(10);

UPDATE sales
SET day_name =dayname(date);

-- Add month_name column

SELECT date, monthname(date)
from sales;

ALTER TABLE sales ADD COLUMN month_name varchar(10);

UPDATE sales
SET month_name = monthname(date);

-- ------------------------GENERIC------------------------------
-- How many unique cities does the data have?
SELECT DISTINCT city
From sales;

-- In which city is each branch?
SELECT DISTINCT city, branch
from sales;

-- ---------------PRODUCT ANALYSIS----------------------------- 
-- How many unique product lines does the data have?
SELECT DISTINCT product_line
from sales;

-- What is the most selling product line
SELECT SUM(quantity) as qty, product_line
from sales
GROUP BY product_line
order by qty desc;

-- What is the total revenue by month
select SUM(total) as total_revenue, month_name as month
from sales
GROUP BY month_name 
order by total_revenue;

-- What month had the largest COGS?
SELECT month_name as month, SUM(cogs) as cogs
from sales
GROUP BY month_name
order by cogs DESC;

-- What product line had the largest revenue?
SELECT product_line, SUM(total)as total_revenue
from sales
Group by product_line
order by total_revenue DESC
LIMIT 1;

-- What is the city with the largest revenue?
SELECT city, SUM(total) as total_revenue
from sales
group by city
order by total_revenue DESC
LIMIT 1;

-- What product line had the largest VAT?
SELECT product_line, SUM(vat) as largest_vat
from sales
group by product_line
order by largest_vat DESC
LIMIT 1;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT product_line,
	CASE 
		WHEN avg(quantity) >=5.4 THEN "Good"
        ELSE "Bad"
	END as Feedback
from sales
group by product_line;

-- Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) as qty
FROM sales
Group by branch
having sum(quantity)>(SELECT avg(quantity) from sales)
LIMIT 1;

-- What is the most common product line by gender
SELECT gender, product_line, COUNT(gender) as tot_cnt
FROM sales
group by gender, product_line
order by tot_cnt DESC;

-- What is the average rating of each product line
SELECT ROUND(AVG(rating),2) as avg_rating, product_line
from sales
group by product_line
order by avg_rating;


-- ------------------------SALES ANALYSIS-------------------
-- Number of sales made in each time of the day per weekday 
SELECT time_of_day, COUNT(*) AS total_sales
from sales
where day_name = "Sunday"
group by time_of_day
order by total_sales;

-- Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) as total_revenue
from sales
group by customer_type
order by total_revenue desc;

-- Which city has the largest tax/VAT percent?
SELECT city, ROUND(AVG(vat), 2) AS avg_vat
FROM sales
GROUP BY city 
ORDER BY avg_vat DESC;

-- Which customer type pays the most in VAT?
select customer_type, AVG(VAT) AS tot_vat
from sales
group by customer_type
ORDER BY tot_vat DESC;


