insert into mart.f_customer_retention (new_customers_count, returning_customers_count, refunded_customer_count,
    period_name, period_id, item_id, new_customers_revenue, returning_customers_revenue, customers_refunded)
with cnt_sales as (
    select 
        fs.item_id item_id,
        fs.customer_id customer_id,
        fs.status status,
        dc.week_of_year as period_id,
        sum(payment_amount) as payment_amount,
        count(*) as cnt
    from mart.f_sales fs
    join mart.d_calendar dc 
        on fs.date_id = dc.date_id 
        and dc.week_of_year = extract('week' from '{{ ds }}'::date)
    group by item_id, customer_id, status, period_id)
SELECT
    sum(case when cnt=1 then 1 end) new_customers_count,
    coalesce(sum(case when cnt>1 then 1 end), 0) returning_customers_count,
    coalesce(sum(case when status = 'refunded' then 1 end), 0) refunded_customer_count,
    'weekly' period_name,
    period_id,
    item_id,
    sum(case when cnt=1 then payment_amount end) new_customers_revenue,
    coalesce(sum(case when cnt>1 then payment_amount end), 0) returning_customers_revenue,
    coalesce(sum(case when status = 'refunded' then payment_amount end), 0) customers_refunded
from cnt_sales
group by period_name, period_id, item_id;
