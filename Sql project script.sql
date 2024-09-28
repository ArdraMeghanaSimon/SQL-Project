select distinct c.market from gdb023.dim_customer c
where c.customer='Atliq Exclusive' 
&& c.region ="APAC";

WITH a_2021 AS (
SELECT COUNT(DISTINCT(product_code)) AS product_count_2021
FROM gdb023.fact_sales_monthly
WHERE fiscal_year = "2021"
),
a_2020 AS (
SELECT COUNT(DISTINCT(product_code)) AS product_count_2020
FROM gdb023.fact_sales_monthly
WHERE fiscal_year = "2020"
)
-- Main query to reference CTEs
SELECT a_2021.product_count_2021, a_2020.product_count_2020, ((a_2021.product_count_2021- a_2020.product_count_2020)/(a_2020.product_count_2020)*100)
FROM a_2021, a_2020;

with a1 as (
select a.segment, count(distinct(a.product_code)) as p1
from gdb023.dim_product a
join fact_sales_monthly f
on a.product_code = f.product_code
where f.fiscal_year="2020"
group by a.segment
order by count(distinct(a.product_code)) desc),

a2 as (select a.segment, count(distinct(a.product_code)) as p2
from gdb023.dim_product a
join fact_sales_monthly f
on a.product_code = f.product_code
where f.fiscal_year="2021"
group by a.segment
order by count(distinct(a.product_code)) desc)

select a1.segment, a1.p1,a2.p2, a2.p2-a1.p1
from a1,a2
order by a2.p2-a1.p1 desc
limit 1;


(select f.manufacturing_cost, d.product,d.product_code
from dim_product d inner join fact_manufacturing_cost f
on d.product_code=f.product_code
order by f.manufacturing_cost desc
limit 1)
UNION ALL
(select f.manufacturing_cost, d.product,d.product_code
from dim_product d inner join fact_manufacturing_cost f
on d.product_code=f.product_code
order by f.manufacturing_cost
limit 1);


select c.customer_code,c.customer,avg(f.pre_invoice_discount_pct) from dim_customer c join fact_pre_invoice_deductions f
on c.customer_code=f.customer_code
where f.fiscal_year="2021" and c.market="India"
group by c.customer_code,c.customer
order by avg(f.pre_invoice_discount_pct) desc
limit 5;

select month(date) as month,f1.fiscal_year, sum(f2.sold_quantity*f1.gross_price) as sales
from fact_gross_price f1 join fact_sales_monthly f2
join dim_customer d1
on d1.customer_code = f2.customer_code
on f1.product_code=f2.product_code
where d1.customer="Atliq Exclusive"
group by month(date),f1.fiscal_year;

with channel as(
select d.channel,sum(f.sold_quantity) as total_channel_sales
from dim_customer d inner join fact_sales_monthly f
on d.customer_code=f.customer_code
and f.fiscal_year=2021
group by d.channel),

total as (
select sum(f.sold_quantity) as total_sales from fact_sales_monthly f
where f.fiscal_year=2021)

select channel, total_channel_sales, (total_channel_sales/total_sales)*100
from channel, total
order by (total_channel_sales/total_sales)*100 desc
limit 1;

select d.division,d.product_code,d.product,sum(f.sold_quantity), dense_rank() over (order by sum(f.sold_quantity) desc) from dim_product d
inner join fact_sales_monthly f
on d.product_code=f.product_code
where f.fiscal_year=2021
group by d.division,d.product_code,d.product
order by sum(f.sold_quantity) desc
limit 3;
