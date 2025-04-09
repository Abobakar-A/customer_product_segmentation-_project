/*
================================================================================================================
Customer Report
================================================================================================================
Purpose:
This report consolidate key customer metrics and behaviors
Highlights:
1.Gather essential fields such as names ages and transaction details .
2. Segment customers into categories (VIP,Regular,New ) 
3.Aggregates customer_level metrics :
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
   create view  gold_report_customers as 
   /*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1) Base Query : Retrive core columns from tables 
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  */
  with base_query as(
  select 
  f.order_number,
  f.product_key,
  f.order_date,
  f.sales_amount,
  f.quantity,
  c.customer_key,
  c.customer_number,
  concat(c.first_name,' ',c.last_name) customer_name, 
 YEAR(CURDATE()) - YEAR(birthdate) AS age

  from
  gold_fact_sales f 
  left join gold_dim_customers c
on c.customer_key=f.customer_key  
where order_date is not null
),
customer_aggregation as(
SELECT
  customer_key,
  customer_number,
  customer_name,
  age,
  COUNT(DISTINCT order_number) AS total_orders,
  SUM(sales_amount) AS total_sales,
  SUM(quantity) AS total_quantity,
  COUNT(DISTINCT product_key) AS total_product,
  MAX(order_date) AS last_order,
  (YEAR(MAX(order_date)) - YEAR(MIN(order_date))) * 12 +
  (MONTH(MAX(order_date)) - MONTH(MIN(order_date))) AS life_span
FROM
  base_query
GROUP BY
  customer_key,
  customer_number,
  customer_name,
  age
  )
  
  
  select
 customer_key,
 customer_number,
 customer_name,
  age,
  case when age < 20 then 'under 20'
             when age between 20 and 29 then '20-29'
             when age between 30 and 40 then '30-49'
               when age between 40 and 49 then '30-49'
               else '50 and above'
               end age_group,
 total_orders,
 total_sales,
 total_quantity,
 total_product,
 last_order,
 life_span,
 TIMESTAMPDIFF(MONTH,(last_order), CURRENT_DATE) recency,
 case when total_orders =0 then 0 
 else
 total_sales/total_orders 
 end as avg_order_value,
 case when life_span =0 then total_sales
 else
 total_sales/life_span 
 end as avg_monthly_spend,

 
   CASE when life_span>=12 and total_sales>5000 then 'VIP'
               when life_span >=12 and total_sales <=5000 then 'Regular'
               else 'New'
               end customer_segment
 from 
 customer_aggregation 
  
  
