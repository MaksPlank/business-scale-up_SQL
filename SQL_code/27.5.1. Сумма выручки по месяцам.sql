-- PROJECT-2. Решение бизнес-задач с помощью SQL 
-- 27.5.1. Сумма выручки по месяцам
----------------------------------------------------------------------------------------

-- CTE z: Таблица для выделения месяца из даты, расчета выручки с учетом скидки
With z AS( 
SELECT 
d.order_date,
to_char(d.order_date, 'YYYY-MM-01') date_by_mnth,
CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END revenue
	
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 
ORDER BY 1
)
-- Расчет итоговой выручки по месяцам, c округлением:
SELECT
date_by_mnth,
round(SUM(revenue),0) sum_revenue
FROM z
GROUP BY 1
ORDER BY 1
----------------------------------------------------------------------------------------
