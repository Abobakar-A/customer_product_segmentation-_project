/*
================================================================================================================
Product  Report
================================================================================================================
Purpose:
This report consolidate key product  metrics and behaviors
Highlights:
1.Gather essential fields such as names, category, subcategory and cost details .
2. Segment product  into categories by revenue to identify  High-Performance,Mid-Range and low-performance . 
3.Aggregates products-level metrics :
 - total orders.
 - total sales.
 - total quantity purchased.
 - total products .
 - lifespanse (in months)
4. Clculatesvaluable KPIS :
 - recency( months since last order) .
  - average order value .
   - average monthly spend
     ===============================================================================================================
   */
  create view gold_report_products as
   /*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1) Base Query : Retrive core columns from tables 
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  */
    with base_query as(
  select 
  f.order_number,
  f.order_date,
  f.customer_key,
  f.quantity,
  sales_amount,
  p.product_key,
  p.product_name,
  p.category,
  p.subcategory,
  p.cost
  from
  gold_fact_sales f 
  left join gold_dim_products p
on f.product_key=p.product_key
where order_date is not null
),
product_aggregation as(
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Product aggregations : summaize  key metrics at product level
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
select
product_key,
product_name,
category,
subcategory,
cost,
quantity,
MAX(month(order_date))-MIN(month(order_date)) as lifespan,
COUNT(DISTINCT order_number) total_orders,
COUNT(DISTINCT customer_key) total_customers,
SUM(sales_amount) total_sales,
SUM(quantity) total_quantity,
MAX(order_date) last_date,
AVG(sales_amount)/ nullif(quantity,0) avg_selling_price
from
base_query
GROUP BY
product_key,
product_name,
category,
subcategory,
cost,
quantity
)
/*
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Final query combins all products results into one out put 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
select
product_key,
product_name,
category,
subcategory,
cost,
last_date,
TIMESTAMPDIFF(MONTH, last_date, CURRENT_DATE) AS recency,
case
 when  total_sales>50000    then 'High-performance'
 when total_sales>=10000 then 'Mid-Range'
 else 'Low-Performance'
 end product_segment,
 lifespan,
 total_orders,
 total_sales,
 total_quantity,
 total_customers,
 avg_selling_price,
 -- avg order revenue 
 case when total_orders=0 then 0
 else total_sales/total_orders
 end avg_order_revenu,
 -- avg monthly revenu
 case
 when lifespan =0 then total_sales
 else total_sales/lifespan
 end avg_monthly_revenu
 from product_aggregation



 
