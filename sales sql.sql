--find top 10 highest revenue generating products
select top 10 product_id, sum(sale_price) as sales from df_orders
GROUP BY product_id
ORDER by sales DESC


--top 5 highest selling products in each region

--using cte
with cte as (
select region, product_id, sum(sale_price) as sales from df_orders
GROUP BY region,product_id)

select region,product_id,sales,rn
from (
select region, product_id, sales
, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn <=5

--only using sub query
select product_id, region, sales
from(
select product_id, region, sum(sale_price) as sales,
row_number() over(partition by region order by sum(sale_price) desc) as rn
from df_orders
group by region, product_id
) AS r
where rn<=5

--select * from df_orders


--month over month sales for year 2022 and 2023

with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
	)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month

--without cte

select month(order_date) as order_month,
Sum(case when year(order_date)=2022 then (sale_price) else 0 end) as sales_2022,
sum(case when year(order_date) = 2023 then (sale_price) else 0 end)as sales_2023
from df_orders
group by month(order_date)
order by order_month


-- for each category which month had higher sales

with cte as (
select category, format(order_date, 'yyyy/MM') as order_year_month, sum(sale_price) as sales
from df_orders
group by category, format(order_date, 'yyyy/MM')
)
select * from ( 
select*,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn = 1

--which sub category had highest growth by profit in 2023 compare to 2022

with cte as (
select sub_category, year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select top 1 *
, (sales_2023-sales_2022)*100/sales_2022 as growth_percentage
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc

