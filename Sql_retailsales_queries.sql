-- Database creation --
create database rs;
use rs;

select * from retailsales;

select count(*) from retailsales;

                      -- Understand the dataset --
			    -- Data-quality assessment and cleaning--
SELECT 
    *
FROM
    retailsales;
SELECT 
    COUNT(*) AS total_records
FROM
    retailsales;
describe retailsales;

SELECT 
    sale_date, sale_time
FROM
    retailsales
LIMIT 10;

-- changing string to date and time --

alter table retailsales
modify column sale_date date;

alter table retailsales
modify column sale_time time;

describe retailsales;

-- Check null values --

SELECT 
    SUM(CASE
        WHEN transactions_id IS NULL THEN 1
        ELSE 0
    END) AS null_transaction_id,
    SUM(CASE
        WHEN sale_date IS NULL THEN 1
        ELSE 0
    END) AS null_sale_date,
    SUM(CASE
        WHEN sale_time IS NULL THEN 1
        ELSE 0
    END) AS null_sale_time,
    SUM(CASE
        WHEN customer_id IS NULL THEN 1
        ELSE 0
    END) AS null_customer_id,
    SUM(CASE
        WHEN gender IS NULL THEN 1
        ELSE 0
    END) AS null_gender,
    SUM(CASE
        WHEN age IS NULL THEN 1
        ELSE 0
    END) AS null_age,
    SUM(CASE
        WHEN category IS NULL THEN 1
        ELSE 0
    END) AS null_category,
    SUM(CASE
        WHEN quantiy IS NULL THEN 1
        ELSE 0
    END) AS null_quantiy,
    SUM(CASE
        WHEN price_per_unit IS NULL THEN 1
        ELSE 0
    END) AS null_price_per_unit,
    SUM(CASE
        WHEN cogs IS NULL THEN 1
        ELSE 0
    END) AS null_cogs,
    SUM(CASE
        WHEN total_sale IS NULL THEN 1
        ELSE 0
    END) AS null_total_sale
FROM
    retailsales;

-- Check duplicate transaction ids using subquery in the from clause --

SELECT 
    transactions_id, COUNT(*) AS duplicate_count
FROM
    retailsales
GROUP BY transactions_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

SELECT 
    COUNT(*) AS duplicated_transaction_ids
FROM
    (SELECT 
        transactions_id, COUNT(*) AS duplicate_count
    FROM
        retailsales
    GROUP BY transactions_id
    HAVING COUNT(*) > 1) AS duplicates;

SELECT 
    transactions_id,
    sale_date,
    sale_time,
    customer_id,
    gender,
    age,
    category,
    quantiy,
    price_per_unit,
    cogs,
    total_sale,
    COUNT(*) AS duplicate_count
FROM
    retailsales
GROUP BY transactions_id , sale_date , sale_time , customer_id , gender , age , category , quantiy , price_per_unit , cogs , total_sale
HAVING COUNT(*) > 1;

-- Check invalid ages -- 

SELECT 
    MIN(age) AS minimum_age,
    MAX(age) AS maximum_age,
    ROUND(AVG(age), 2) AS average_age
FROM
    retailsales;

SELECT 
    *
FROM
    retailsales
WHERE
    age < 16 OR age > 100;
   
   -- Check quantity --
   
SELECT 
    MIN(quantiy) AS minimum_quantity,
    MAX(quantiy) AS maximum_quantiy,
    AVG(quantiy) AS average_quantity
FROM
    retailsales;
   
SELECT 
    *
FROM
    retailsales
WHERE
    quantiy <= 0 OR quantiy IS NULL;
   
   
-- Check prices--

SELECT 
    MAX(price_per_unit) AS maximum,
    MIN(price_per_unit) AS minimum,
    AVG(price_per_unit) AS average_price
FROM
    retailsales;
  
SELECT 
    *
FROM
    retailsales
WHERE
    price_per_unit <= 0
        OR price_per_unit IS NULL;
  
-- Validate cogs --

SELECT 
    *
FROM
    retailsales
WHERE
    cogs < 0 OR cogs IS NULL;
   
SELECT 
    transactions_id,
    category,
    total_sale,
    cogs,
    total_sale - cogs AS gross_profit
FROM
    retailsales
WHERE
    cogs > total_sale;

-- Validate total sales -- 

SELECT 
    transactions_id,
    quantiy,
    price_per_unit,
    total_sale,
    ROUND(quantiy * price_per_unit, 2) AS calculated_sale,
    ROUND(total_sale - (quantiy * price_per_unit),
            2) AS difference
FROM
    retailsales
WHERE
    ABS(total_sale - (quantiy * price_per_unit)) > 0.01;

-- Check inconsistent gender values--

SELECT 
    gender, COUNT(*) AS records
FROM
    retailsales
GROUP BY gender
ORDER BY records DESC;

SELECT 
    category, COUNT(*) AS category_count
FROM
    retailsales
GROUP BY category
ORDER BY category_count ASC;

-- Check date coverage -- 

SELECT 
    MIN(sale_date) AS first_transaction,
    MAX(sale_date) AS last_transaction,
    DATEDIFF(MAX(sale_date), MIN(sale_date)) AS dataset_period_days
FROM
    retailsales;

SELECT 
    YEAR(sale_date) AS sales_year, COUNT(*) AS transactions
FROM
    retailsales
GROUP BY YEAR(sale_date)
ORDER BY sales_year;

alter table retailsales
rename column quantiy to quantity;

SELECT 
    *
FROM
    retailsales;

                      -- Cleaning complete --
-------------------------------------------------------------------------------------------                      
			  -- Business KPI and Profitablility analysis --
-- Overall business KPIs --
 
 SELECT category,
    COUNT(DISTINCT transactions_id) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(total_sale), 2) AS total_revenue,
    SUM(cogs) AS total_cogs,
    SUM(total_sale - cogs) AS gross_profit,
    ROUND(AVG(total_sale), 2) AS avg_value,
    
 -- calculate gross margin %  and revenue vs profit by category --   
 
    ROUND(sum(total_sale - cogs)/sum(total_sale) * 100, 2) as gross_margin_pct
    
FROM
    retailsales
    group by category
    order by gross_profit desc;
    
-- Revenue contribution % --
    
SELECT
    category,
    ROUND(SUM(total_sale), 2) AS revenue,

    ROUND(
        SUM(total_sale)
        / SUM(SUM(total_sale)) over() * 100,
        2
    ) AS revenue_contribution_pct

FROM retailsales

GROUP BY category

ORDER BY revenue DESC;
    
-- Customer value analysis --

select 
customer_id,
    COUNT(distinct transactions_id) as transactions,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(total_sale), 2) AS total_revenue,
	SUM(total_sale - cogs) AS gross_profit,
    
    round(sum(total_sale - cogs)/SUM(total_sale) * 100, 2) as gross_margin_pct 
    
    

from retailsales
group by customer_id
order by total_revenue desc
limit 10;


select * from retailsales;
 
SELECT 
    ROUND(
        SUM(total_sale) /
        NULLIF(COUNT(DISTINCT customer_id), 0),
        2
    ) AS revenue_per_customer
FROM retailsales;


-- Write a SQL query to retrieve all transactions where the category is clothing and the quantity sold is more than 10 in the month of November 2022

select sale_date, category, quantiy from retailsales
where category = 'Clothing' and
year(sale_date) = 2022 and month(sale_date) = 11
and quantiy >= 4;


-- Write a SQL query to calculate the total sales (total sales) for each category 

select category, sum(total_sale) as Net_sale, 
count(*) as Total_orders
from retailsales
group by 1;

-- write a sql query to find the average age of customers who purchased items from The beauty category

select round(avg(age), 2) from retailsales
where category = 'beauty';

-- Write a SQL query to find all transactions where the total sale is greater than 1000

select * from retailsales
where total_sale > 1000;

-- Write a sequel query to find the total number of transactions transaction ID made by each gender in each category

select gender, category, count(*) from retailsales
group by 1,2
order by 1;

-- write a SQL query to calculate the average sale for each month find out best selling month in each year
select year, month, avg_sale
 from (
			select 
			year(sale_date) as year,
			month(sale_date) as month,
			avg(total_sale) as avg_sale, 
			rank() over (partition by year(sale_date) order by avg(total_sale) desc) as position
			from retailsales
			group by 1,2
) as sq
where position = 1;

-- Write a sql query to find the top 5 customers based on the highest total sales

select customer_id, sum(total_sale)
from retailsales
group by 1
order by 2 desc
limit 5;

-- Write is sql query to find the number of unique customer who purchased items from each category

select 
count(distinct customer_id), 
category from retailsales
group by 2;

-- Write a SQL query to create each shift and number of orders example morning less than or equal to 12, afternoon between 12 and 17 evenings greater than 17
with hourly_sale
as (
select *,
	case
		when hour(sale_time) < 12  then 'morning'
		when hour(sale_time) between 12 and 17 then 'afternoon'
	else 'evening'
	end as shift
from retailsales
)
select shift, 
count(*) as total_orders
from hourly_sale
group by shift
order by 2 desc;




