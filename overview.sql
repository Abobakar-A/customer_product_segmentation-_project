USE datawharehouseanalytics;
RENAME TABLE  `gold.fact_sales` TO `gold_fact_sales` ;
RENAME TABLE  `gold.dim_customers` TO `gold_dim_customers`;
RENAME TABLE  `gold.dim_products` TO `gold_dim_products`;

/* calculat  total sales per month
and the running total sales over time
*/
select
order_date,
total_sales,
sum(total_sales) over(PARTITION BY order_date order by order_date) as running_total
from
(
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_date,
    SUM(sales_amount) AS total_sales
FROM gold_fact_sales
WHERE DATE_FORMAT(order_date, '%Y-%m') IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)  sub;

/* Analyze the yearly performance of products by comparing  their sales 
to both average sales performance of the product  and the previous year's sales 
*/
with yearly_sales_product as(
select
year(f.order_date)    order_year,
p.product_name,
sum(f.sales_amount)  current_sales
from
gold_fact_sales f
left join gold_dim_products p
on f.product_key=p.product_key
where year(f.order_date) is not null
group by year(f.order_date),p.product_name
)
select
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
current_sales-AVG(current_sales) OVER(PARTITION BY product_name)  diff_avg,
CASE when current_sales-AVG(current_sales) OVER(PARTITION BY product_name)  > 0 then 'above avg'
 when current_sales-AVG(current_sales) OVER(PARTITION BY product_name)  < 0 then 'below avg'
 else 'avg'
 end avg_change,
 lag(current_sales) over(PARTITION BY product_name order by order_year) py_sales,
 current_sales- lag(current_sales) over(PARTITION BY product_name order by order_year) diff_py,
 CASE when current_sales- lag(current_sales) over(PARTITION BY product_name order by order_year) > 0 then 'increase'
 when current_sales- lag(current_sales) over(PARTITION BY product_name order by order_year) <0 then 'decrease'
 else 'no change'
 end py_change
from yearly_sales_product
order by product_name,order_year;

-- which categories contribute the most to overall sales
with category_sales as (
select
category,
sum(sales_amount)  total_sales
from gold_fact_sales  f
left join gold_dim_products p
on f.product_key=p.product_key
group by category
  )
  select 
  category,
  total_sales,
  sum(total_sales) over() overall_sales,
concat(round(  (total_sales/sum(total_sales) over() )*100,2),'%') percentage_of_total
  from
  category_sales 
  ORDER BY total_sales desc;
  
  /* 
  segment products into cost range and 
  count how many products fall into each segment
  */
  with product_segment  as(
  select 
  product_key,
  product_name,
  cost,
  CASE when cost <100 then 'below 100'
               when cost between 100 and 500  then '100-500'
                when cost between 500 and 1000  then '100-500'
  else 'above 1000'
  end cost_range
  from 
  gold_dim_products
  )
  
  select 
  COUNT(product_key) total_product,
  cost_range 
  from
product_segment
GROUP BY cost_range;
  
  /*
  Group customers into three segments based on their spending beheviour :
  - VIP :customers with at least 12 moths of history and spending more than 5000.
  -Regular customers with at least 12 months of history but spending  5000 or less . 
  -New customers with life span less than 12 months. 
  and find total number of customers by each group . 
  
  */
with customer_spending as(
 SELECT 
  c.customer_key,
  SUM(f.sales_amount) AS total_spending,
  MIN(f.order_date) AS first_order,
  MAX(f.order_date) AS last_order,
  DATEDIFF(MAX(f.order_date), MIN(f.order_date)) / 30 AS life_spane
FROM 
  gold_fact_sales f
LEFT JOIN gold_dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
  )
  ,a as  (
  select 
  customer_key,
  total_spending,
  life_spane,
  CASE when life_spane >=12 and total_spending >5000 then 'VIP'
               when life_spane >=12 and total_spending <=5000 then 'Regular'
               else 'New'
               end customer_segment
  from
  customer_spending 
  )
  
  
  select
  count(customer_key),
  customer_segment
  from a
  group by customer_segment;


