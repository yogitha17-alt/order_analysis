select * from df_orders;

--top 10 selling products
select top 10 product_id, sum(sale_price) as sd from df_orders
group by product_id
order by sd desc;

--top 5 selling products for each region
with cte as (select region, product_id, sum(sale_price) as sd 
from df_orders
group by product_id, region)
select * from 
(select * ,row_number() over (partition by region order by sd desc) as rn
from cte) sub where rn<= 5;

-- sales growth by month over month for 2022 vs 2023
with cte as (select year(order_date) as yr , month(order_date) as mon, sum(sale_price) as sp from df_orders
 group by year(order_date), month(order_date)
 --order by year(order_date), month(order_date)  (order by is not allowed in cte)
 )
select mon, sum(case when yr = 2022 then sp else 0 end) as sales_2022, 
 sum(case when yr = 2023 then sp else 0 end) as sales_2023 
 from cte
 group by mon
 order by mon;

 -- highest selling month for each category 
with cte as (select category, format(order_date,'yyyyMM') as mon, sum(sale_price) as sp from df_orders
group by category, format(order_date,'yyyyMM'))
select * from
(select *, ROW_NUMBER() over (partition by category order by sp desc) as rn from cte) sub
where rn = 1;

--sub-category which has highest growth percentage by sales from 2022 to 2023
with cte as (select year(order_date) as yr , sub_category, sum(sale_price) as sp from df_orders
 group by year(order_date), sub_category
 --order by year(order_date), month(order_date)  (order by is not allowed in cte)
 ),
cte2 as (select sub_category, sum(case when yr = 2022 then sp else 0 end) as sales_2022, 
 sum(case when yr = 2023 then sp else 0 end) as sales_2023 
 from cte
 group by sub_category)
 select top 1 *, ((sales_2023 - sales_2022)*100/ sales_2022) as growth from cte2
 order by growth desc
 

