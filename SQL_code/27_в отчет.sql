-- PROJECT-2. Решение бизнес-задач с помощью SQL 

----------------------------------------------------------------------------------------

-- 27.5.1 / Сумма выручки по месяцам:
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

-- 27.5.5 / Сумма выручки по категориям/подкатегориям:
-- CTE W: Таблица расчета выручки с учетом скидки для каждой позиции товара:
With w AS(
SELECT
pr.category,
pr.subcategory,
CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END revenue
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 
)
-- Итог из CTE W: группировка всех товаров/их стоимостей в категории/подкатегории:
SELECT
w.category,
w.subcategory,
round(SUM(revenue),0) sum_revenue
FROM w
Group by 1,2
ORDER BY 3 DESC 
----------------------------------------------------------------------------------------

-- 27.5.6 / Запрос, который выведет топ-25 товаров по объёму выручки: 
-- CTE X: для расчета объема всей выручки
/* With x AS(   
SELECT
count(pr.product_nm),
SUM(CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END) total_revenue -- 1446157
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
) */

-- CTE W: таблица выбора 25ти продуктов, лидеров по выручке
With w AS(
SELECT
pr.product_nm,
SUM(ca.quantity) quantity,
sum(CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END) revenue	
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 
GROUP BY 1
ORDER BY 3 DESC	
Limit 25
)
-- Вывод продуктов (топ-25), выручки, количества и % выручки продукта от общей выручки
SELECT
w.product_nm,
round(revenue,2) sum_revenue,
SUM(quantity::integer) sum_quantity,
round((revenue/1446157)*100,2) percent_from_total 
FROM w 
GROUP BY product_nm, revenue
ORDER BY 2 DESC

----------------------------------------------------------------------------------------

-- 27.6.1 / Количество клиентов и выручка по категориям клиента:
-- CTE X: расчет суммарной выручки по каждому клиенту:
With x AS(
SELECT 
d.cust_id,
SUM(CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END) revenue
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 
GROUP BY  1
)
-- Вывод количества клиентов в категориях B2B/B2C и выручки по ним
SELECT	
cu.category, 
COUNT(x.cust_id) count_customers,
Round(SUM(revenue),0) sum_revenue
FROM sql.store_customers cu JOIN x ON cu.cust_id=x.cust_id
GROUP BY cu.category
ORDER BY 3 DESC 

----------------------------------------------------------------------------------------

-- 27.6.2 / Количество новых корпоративных клиентов по месяцам
-- CTE Z: определяет день первой покупки (first_order) у каждого клиента
WITH z AS(
SELECT
ROW_NUMBER() OVER (PARTITION BY d.cust_id ORDER BY d.order_date) first_order,
to_char(d.order_date, 'YYYY-MM-01') first_visit, -- месяц покупки
d.cust_id
FROM sql.store_delivery d
JOIN sql.store_carts ca ON d.order_id = ca.order_id
LEFT JOIN sql.store_customers cu ON cu.cust_id = d.cust_id
WHERE cu.category = 'Corporate'
ORDER BY 2,1
)
-- Вывод количества новых клиентов (first_order = 1) в теущем месяце
SELECT
first_visit,
count(z.cust_id) count_cust
FROM z
WHERE first_order = 1
GROUP BY 1
ORDER BY 1 ASC
----------------------------------------------------------------------------------------

-- 27.6.4 / 1 / Среднее количество различных товаров в заказах у корпоративных клиентов
-- CTE для подсчета кол-ва единиц отдельного товара в заказе
WITH q AS(  
SELECT 
d.order_id orders,
SUM(ca.quantity) quantity_to_order
FROM sql.store_carts ca LEFT JOIN sql.store_delivery d ON ca.order_id=d.order_id 
LEFT JOIN sql.store_customers cu ON d.cust_id=cu.cust_id 
WHERE cu.category = 'Corporate' 
GROUP BY 1
)
-- вывод:
SELECT
count(orders), -- 4100
round(AVG(quantity_to_order),1) avg_quantity -- 7,6
FROM q

----------------------------------------------------------------------------------------

-- 27.6.4 / 2 / Средняя сумма заказов у корпоративных клиентов
-- CTE re: считает сумму каждого заказа 
With re AS( 
SELECT
d.order_id orders,
sum(CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END) revenue_to_order
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 
LEFT JOIN sql.store_customers cu ON d.cust_id=cu.cust_id 
WHERE cu.category = 'Corporate'
GROUP BY 1
)
-- вывод: 
SELECT
count(orders), -- 4100
round(AVG(revenue_to_order),1) avg_revenue -- 285,9
FROM re

----------------------------------------------------------------------------------------

-- 27.6.4 / 3 / Среднее количество различных офисов у корпоративных клиентов 
-- CTE t: считает количество офисов(zip_code) по каждому клиенту
With t AS( 
SELECT 
d.cust_id,  -- 645 distinct
count(distinct d.zip_code) count_office -- 599 distinct
FROM sql.store_delivery d
LEFT JOIN sql.store_customers cu ON cu.cust_id = d.cust_id
WHERE cu.category = 'Corporate'
GROUP BY 1
ORDER BY 1
)
-- считает среднее количество офисов у клиентов
SELECT
round(avg(count_office),1)
FROM t 

----------------------------------------------------------------------------------------

-- 27.7.1 / % заказов выполненных в срок по каждой категории
-- CTE d: считает фактические дни доставки и распределяет нормо дни категориям
WITH d AS(  
SELECT
ship_mode,
d.order_id,
CASE
WHEN ship_mode like 'Standard Class' THEN 6
WHEN ship_mode like 'Second Class' THEN 4
WHEN ship_mode like 'First Class' THEN 3
WHEN ship_mode like 'Same Day' THEN 0
END ship_mode_d,
(d.ship_date - d.order_date - 1) fact_days
FROM sql.store_delivery d
),
-- CTE S: маркирует доставки по времени bad_time(с опозданием)/in_time(вовремя)
s AS(  
SELECT
d.ship_mode,
count(d.order_id) count_orders,
count(CASE WHEN fact_days >= ship_mode_d  THEN 'bad_time' END) late_orders_count,
count(CASE WHEN fact_days < ship_mode_d THEN 'in_time' END) early_orders_count
FROM d
GROUP BY 1
)
-- выводит итог
SELECT
s.ship_mode,       -- тип доставки
count_orders,      -- общее количество заказов
late_orders_count,   -- количество заказов, которые не были доставлены вовремя 
round(early_orders_count::numeric/count_orders*100,2) "% success" -- доля выполненных вовремя заказов
FROM s
GROUP BY s.ship_mode,count_orders,late_orders_count,early_orders_count
ORDER BY 4 ASC 
----------------------------------------------------------------------------------------

-- 27.7.2 / % заказов, отправленных вторым классом, которые были доставлены с опозданием, по кварталам
-- CTE d: считает фактические дни доставки и распределяет нормо дни категориям
WITH d AS(  
SELECT
ship_mode,
d.order_id,
to_char(d.order_date, 'YYYY-Q') ship_quarter,
CASE
WHEN ship_mode like 'Standard Class' THEN 6
WHEN ship_mode like 'Second Class' THEN 4
WHEN ship_mode like 'First Class' THEN 3
WHEN ship_mode like 'Same Day' THEN 0
END ship_mode_d,
(d.ship_date - d.order_date - 1) fact_days
FROM sql.store_delivery d
),
-- CTE X: маркирует доставки по времени bad_time(с опозданием)/in_time(вовремя)
x AS(  
SELECT
ship_quarter,
count(d.order_id) orders_count,
count(CASE WHEN fact_days < ship_mode_d THEN 'in_time' END) early_orders_count,
count(CASE WHEN fact_days >= ship_mode_d  THEN 'bad_time' END) late_orders_count
FROM d
GROUP BY 1 
)
-- итог: % заказов, отправленных вторым классом, которые были доставлены с опозданием,
SELECT
ship_quarter,
orders_count,
early_orders_count,
late_orders_count,
round(late_orders_count::numeric/orders_count*100,2) "%_late_orders" 
FROM x
ORDER BY 1
----------------------------------------------------------------------------------------

-- 27.7.6 / Количество доставок по штатам
SELECT
state,
city,
count(order_id)
FROM sql.store_delivery
GROUP BY 1,2
ORDER BY count(order_id) DESC
----------------------------------------------------------------------------------------
