-- =====================================================
-- RETAIL SALES & CUSTOMER BEHAVIOUR ANALYSIS
-- MySQL
-- =====================================================

-- DATABASE SETUP --

CREATE TABLE retailsales_backup AS SELECT * FROM
    retailsales;
SELECT 
    *
FROM
    retailsales_backup;

                      -- UNDERSTAND DATASET --
			    -- DATA QUALITY ASSESSMENT AND CLEANING --
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
-- -----------------------------------------------------------------------------------------                      
			  -- BUSINESS KPIs AND PROFITABILITY ANALYSIS --
-- OVERALL BUSINESS KPIs --

SELECT 

    COUNT(DISTINCT transactions_id) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(total_sale), 2) AS total_revenue,
    SUM(cogs) AS total_cogs,
    SUM(total_sale - cogs) AS gross_profit,
    ROUND(AVG(total_sale), 2) AS avg_value,
    round(sum(total_sale - cogs)/nullif(sum(total_sale), 0) * 100,2) as gross_margin_pct

from retailsales;
 
 -- CATEGORY & PROFITABILITY ANALYSIS --
 
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
    
-- REVENUE CONTRIBUTION % --
    
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
    
-- CUSTOMER VALUE ANALYSIS --

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
 
  -- ADVANCED MONTHLY SALES TREND ANALYSIS --
  
SELECT 
    YEAR(sale_date) AS sales_year,
    MONTH(sale_date) AS sales_month,
    ROUND(SUM(total_sale), 2) AS monthly_revenue
FROM
    retailsales
GROUP BY YEAR(sale_date) , MONTH(sale_date)
ORDER BY sales_year, sales_month;
 
-- CREATING CTEs --
-- MONTH-ON-MONTH GROWTH --

with monthly_sales as (
SELECT 
    YEAR(sale_date) AS sales_year,
    MONTH(sale_date) AS sales_month,
    ROUND(SUM(total_sale), 2) AS monthly_revenue
FROM
    retailsales
GROUP BY YEAR(sale_date) , MONTH(sale_date)
),
revenue_comparison as (select sales_year, sales_month, monthly_revenue,
lag(monthly_revenue) over (order by sales_year, sales_month
) as previous_month_revenue
from monthly_sales
),

mom_difference as (select sales_year, 
sales_month, 
monthly_revenue, 
previous_month_revenue,
round (
monthly_revenue - previous_month_revenue
) as mom_growth
from revenue_comparison),

mom_pct as (select 
sales_year, 
sales_month, 
monthly_revenue, 
previous_month_revenue,
mom_growth,

round (mom_growth/nullif(previous_month_revenue , 0 ) * 100, 2) as
mom_growth_pct
from mom_difference),

ranking_revenue as (select sales_year, 
sales_month, 
monthly_revenue, 
previous_month_revenue,
mom_growth,
mom_growth_pct,
sum(monthly_revenue) over ( partition by sales_year 
order by sales_month
) as running_total_revenue,

 RANK() OVER (partition by sales_year 
        ORDER BY monthly_revenue DESC
    ) AS best_rank,
    
rank() over (partition by sales_year
order by monthly_revenue asc
) as worst_rank

from mom_pct)

select sales_year, 
sales_month, 
monthly_revenue, 
previous_month_revenue,
mom_growth,
mom_growth_pct,
running_total_revenue,
best_rank,
worst_rank

from ranking_revenue

where best_rank = 1 or
worst_rank = 1;

-- YEAR-ON-YEAR GROWTH --

WITH monthly_sales AS (
    SELECT
        YEAR(sale_date) AS sales_year,
        MONTH(sale_date) AS sales_month,
        ROUND(SUM(total_sale), 2) AS monthly_revenue
    FROM retailsales
    GROUP BY
        YEAR(sale_date),
        MONTH(sale_date)
),

yoy_comparison AS (
    SELECT
        sales_year,
        sales_month,
        monthly_revenue,

        LAG(monthly_revenue) OVER (
            PARTITION BY sales_month
            ORDER BY sales_year
        ) AS previous_year_revenue

    FROM monthly_sales
)

SELECT
    sales_year,
    sales_month,
    monthly_revenue,
    previous_year_revenue,

    ROUND(
        monthly_revenue - previous_year_revenue,
        2
    ) AS yoy_difference,

    ROUND(
        (monthly_revenue - previous_year_revenue)
        / NULLIF(previous_year_revenue, 0)
        * 100,
        2
    ) AS yoy_growth_pct

FROM yoy_comparison
ORDER BY sales_year, sales_month;


select * from retailsales;

-- CUSTOMER VALUE SEGMENTATION -- 

with customer_summary as (select 
customer_id,
count(distinct transactions_id) as total_transaction,
sum(quantity) as total_units,
sum(total_sale) as total_spend,
round(avg(total_sale), 2) as avg_spend_value,
sum(total_sale-cogs) as gross_profit_generated

from retailsales
group by customer_id
)

select *
from customer_summary
order by total_spend desc;

with customer_summary as (select 
customer_id,
count(distinct transactions_id) as total_transaction,
sum(quantity) as total_units,
sum(total_sale) as total_spend,
round(avg(total_sale), 2) as avg_spend_value,
sum(total_sale-cogs) as gross_profit_generated

from retailsales
group by customer_id),

customer_ranking as (select 
customer_id,
total_transaction,
total_units,
total_spend,
avg_spend_value,
gross_profit_generated,

ntile(3) over (
order by total_spend desc
) as spend_group

from customer_summary),

customer_segments as (select 
customer_id,
total_transaction,
total_units,
total_spend,
avg_spend_value,
gross_profit_generated,

case 
when spend_group = 1 then 'High value'
when spend_group = 2 then 'Medium value'
when spend_group = 3 then 'low value'
end as customer_segment

from customer_ranking)

select
customer_segment,
count(customer_id) as customer_count,
sum(total_spend) as segment_revenue,
round(sum(total_spend)/ sum(sum(total_spend)) over() * 100, 2) as revenue_contribution_pct,
round(sum(total_spend), 2) as avg_segment_revenue,
sum(gross_profit_generated) as segment_profit

from customer_segments

group by customer_segment
order by segment_revenue desc;

-- REPEATE CUSTOMER / PURCHASE FREQUENCY ANALYSIS --

WITH customer_frequency AS (
    SELECT
        customer_id,
        COUNT(DISTINCT transactions_id) AS total_transactions,
        ROUND(SUM(total_sale), 2) AS total_spend
    FROM retailsales
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN total_transactions = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,

    COUNT(customer_id) AS customer_count,

    ROUND(SUM(total_spend), 2) AS total_revenue,

    ROUND(AVG(total_spend), 2) AS avg_customer_spend

FROM customer_frequency

GROUP BY
    customer_type

ORDER BY total_revenue DESC;
 

with customer_frequency as (select 
customer_id,
count(distinct transactions_id) as total_transactions
from retailsales
group by customer_id)

select 
total_transactions,
count(customer_id) as customer_count
from customer_frequency

group by total_transactions
order by total_transactions;


SELECT
    customer_id,
    COUNT(DISTINCT transactions_id) AS total_transactions,
    SUM(quantity) AS total_units,
    ROUND(SUM(total_sale), 2) AS total_spend,
    MIN(sale_date) AS first_purchase,
    MAX(sale_date) AS last_purchase
FROM retailsales
GROUP BY customer_id
HAVING COUNT(DISTINCT transactions_id) > 25
ORDER BY total_transactions DESC;

-- PURCHASE FREQUENCY ANALYSIS -- 

WITH customer_frequency AS (
    SELECT
        customer_id,
        COUNT(DISTINCT transactions_id) AS total_transactions,
        ROUND(SUM(total_sale), 2) AS total_spend
    FROM retailsales
    GROUP BY customer_id
),

frequency_ranking AS (
    SELECT
        customer_id,
        total_transactions,
        total_spend,

        NTILE(3) OVER (
            ORDER BY total_transactions DESC
        ) AS frequency_group

    FROM customer_frequency
),

frequency_segments AS (
    SELECT
        customer_id,
        total_transactions,
        total_spend,

        CASE
            WHEN frequency_group = 1 THEN 'High Frequency'
            WHEN frequency_group = 2 THEN 'Medium Frequency'
            WHEN frequency_group = 3 THEN 'Low Frequency'
        END AS frequency_segment

    FROM frequency_ranking
)

SELECT
    frequency_segment,
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(total_transactions), 2) AS avg_transactions,
    ROUND(SUM(total_spend), 2) AS total_revenue,
    ROUND(AVG(total_spend), 2) AS avg_customer_spend
FROM frequency_segments
GROUP BY frequency_segment
ORDER BY avg_transactions DESC;

select * from retailsales;
