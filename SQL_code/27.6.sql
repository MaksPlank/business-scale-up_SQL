/*
sql.store_customers cu КЛИЕНТЫ 
    ** cu.cust_id     ::varchar   / id клиента <<<
	-- cu.cust_nm     ::text      / имя клиента
	-- cu.category    ::text      / 'Consumer' (B2C-клиент,розничный пок.), 'Corporate' (B2B-клиент,компания)
	
sql.store_products pr ТОВАР 
	** pr.product_id  ::varchar  / id товара <<
	-- pr.category    ::text     / категория товара
	-- pr.subcategory ::text     / подкатегория товара
	-- pr.product_nm  ::text     / название, свойства: цвет, модель, бренд итд
	-- pr.price       ::numeric  / цена товара
	
sql.store_carts ca ТОВАР  //  d.order_id = ca.order_id  /  pr.product_id = ca.product_id
	<< ca.order_id    ::varchar  / id заказа >>> store_delivery
	<< ca.product_id  ::varchar  / id товара >>> store_products
	-- ca.id          ::integer  / id записи в таблице
	-- ca.quantity    ::integer  / кол-во единиц отдельного товара в заказе
	-- ca.discount    ::numeric  / доля скидки на определённый товар; 0.1 = 10% 
	
sql.store_delivery d ЗАКАЗЫ и ДОСТАВКА // d.order_id = ca.order_id / cu.cust_id = d.cust_id
	** d.order_id     ::varchar  / id заказа <<
	<< d.cust_id      ::varchar  / id клиента >>> store_customers
	-- d.order_date   ::date     / дата заказа
	-- d.ship_date    ::date     / фактическая дата доставки
	-- d.ship_mode    ::text     / тип доставки
	-- d.state        ::text     / штат доставки
	-- d.city         ::tex      / город доставки
	-- d.zip_code     ::tex      / индекс доставки */
	



-- 27.4.1_Заказы по предоставленным данным 'осуществлялись' 
-- с 03/01/2017 по 30/12/2020гг
/* 
SELECT 
max(order_date), -- 2020-12-30
min(order_date) -- 2017-01-03
FROM sql.store_delivery */


-- 27.4.2_Всего 5009 заказов было выполнено за данный период
/*
SELECT 
count(order_date) -- 5009
FROM sql.store_delivery */


-- 27.4.3_Объём общей выручки = 1 446 157 руб.
--pr.product_id, pr.product_nm, pr.price, ca.quantity,ca.discount,
/*
With x AS(   
SELECT
SUM(CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END) revenue
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
) */


-- 27.5.1_Cумма выручки по месяцам:
/*
With z AS( 
SELECT 
d.order_date,
to_char(d.order_date, 'YYYY-MM-01') date,
CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END rev
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 
ORDER BY 1
)
SELECT
date,
round(SUM(rev),0) revenue
FROM z
GROUP BY 1
ORDER BY 1  */


-- 27.5.5_Сумма выручки по различным категориям и подкатегориям:
/*
With w AS(
SELECT
pr.category,
pr.subcategory,
CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END rev
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 
)
SELECT
w.category,
w.subcategory,
round(SUM(rev),0) revenue
FROM w
Group by 1,2
ORDER BY 3 DESC */


-- 27.5.6_Топ-25 товаров по объёму выручки: 
/*
With w AS(
SELECT
pr.product_nm product_nm,
SUM(ca.quantity) q,
sum(CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END) revenue
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 
Group by 1
ORDER BY 3 DESC	
Limit 25
)
SELECT
product_nm,
round(revenue,2),
SUM(q::integer) as quantity,
round((revenue/1446157)*100,2) percent_from_total 
FROM w 
GROUP BY product_nm, revenue
ORDER BY 2 DESC
*/

-- 27.6.1_Количество клиентов и выручка по категориям клиента:
-- Corporate	645	 1172009
-- Consumer	    148	 274148 
/*
With x AS(
SELECT
d.cust_id,
sum(CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END) revenue
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 
Group by 1
)
SELECT	
cu.category, 
count(x.cust_id) as cust_cnt,
Round(SUM(revenue),0) revenue
FROM sql.store_customers cu JOIN x ON cu.cust_id=x.cust_id
Group by cu.category
ORDER BY 3 DESC */



--  27.6.2 / Количество новых корпоративных клиентов по месяцам
/*
"2017-01-01"	29
"2017-02-01"	19
"2017-03-01"	51
"2017-04-01"	44
"2017-05-01"	47
"2017-06-01"	42
"2017-07-01"	33
"2017-08-01"	40
"2017-09-01"	56
"2017-10-01"	35
"2017-11-01"	51
"2017-12-01"	43
"2018-01-01"	6
"2018-02-01"	6
"2018-03-01"	16
"2018-04-01"	10
"2018-05-01"	9
"2018-06-01"	8
"2018-07-01"	7
"2018-08-01"	8
"2018-09-01"	10
"2018-10-01"	8
"2018-11-01"	7
"2018-12-01"	8
"2019-01-01"	5
"2019-02-01"	2
"2019-03-01"	6
"2019-04-01"	3
"2019-05-01"	7
"2019-06-01"	7
"2019-07-01"	2
"2019-08-01"	2
"2019-10-01"	1
"2019-11-01"	5
"2019-12-01"	2
"2020-03-01"	3
"2020-04-01"	1
"2020-06-01"	1
"2020-07-01"	2
"2020-09-01"	1
"2020-10-01"	1
"2020-11-01"	1 

With z AS( 
SELECT 
ROW_NUMBER() OVER (PARTITION BY d.cust_id ORDER BY d.order_date) rnk,
d.order_date,
to_char(d.order_date, 'YYYY-MM-01') first_visit,
ca.order_id,
d.cust_id
FROM sql.store_delivery d
JOIN sql.store_carts ca ON d.order_id = ca.order_id 
LEFT JOIN sql.store_customers cu ON cu.cust_id = d.cust_id
WHERE cu.category = 'Corporate'
ORDER BY 2,1
)
SELECT
first_visit, 
count(z.cust_id) -- кол-во нов.клиентов (rnk = 1 в теущем месяце)
FROM z
WHERE rnk != 1 
GROUP BY 1
ORDER BY 1 ASC */

-- + количество новых розничных клиентов по месяцам
/*
With z AS( 
SELECT 
ROW_NUMBER() OVER (PARTITION BY d.cust_id ORDER BY d.order_date) rnk,
d.order_date,
to_char(d.order_date, 'YYYY-MM-01') first_visit,
ca.order_id,
d.cust_id
FROM sql.store_delivery d
JOIN sql.store_carts ca ON d.order_id = ca.order_id 
LEFT JOIN sql.store_customers cu ON cu.cust_id = d.cust_id
WHERE cu.category = 'Consumer'
ORDER BY 2,1
)
SELECT
first_visit, 
count(z.cust_id) -- кол-во нов.клиентов (rnk = 1 в теущем месяце)
FROM z
WHERE rnk = 1 
GROUP BY 1
ORDER BY 1 ASC */

-- Всего клиентов по месяцам + выручка
/*
With z AS( 
SELECT 
ROW_NUMBER() OVER (PARTITION BY d.cust_id ORDER BY d.order_date) rnk,
d.order_date,
to_char(d.order_date, 'YYYY-MM-01') first_visit,
ca.order_id,
d.cust_id,
CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END revenue
FROM sql.store_products pr JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 	
ORDER BY 2,1
)
SELECT
first_visit,
count(z.cust_id),
round(sum(revenue),0)
FROM z JOIN sql.store_customers cu ON z.cust_id = cu.cust_id
WHERE rnk != 1 
and cu.category = 'Corporate'
-- and cu.category = 'Consumer'
GROUP BY 1
ORDER BY 1 ASC */

-- 27.6.4
-- 1. Какая в среднем сумма заказов у корпоративных клиентов?
/*
With x AS( 
SELECT 
-- ROW_NUMBER() OVER (PARTITION BY d.cust_id ORDER BY d.order_date) rnk,
-- to_char(d.order_date, 'YYYY-MM-01') first_visit,
d.order_date,
ca.order_id,
d.cust_id,
CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END revenue
FROM sql.store_products pr JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 	
ORDER BY 1
)
SELECT
count(x.order_id),
count(x.cust_id),
Round(SUM(revenue),0) sum_revenue,
Round(AVG(revenue),0) avg_revenue,
Round(max(revenue),0) max_revenue,
Round(min(revenue),0) min_revenue
FROM x JOIN sql.store_customers cu ON x.cust_id = cu.cust_id
WHERE cu.category = 'Corporate'
--WHERE cu.category = 'Consumer'
ORDER BY 1 ASC */


-- 2. Сколько в среднем различных товаров в заказах у корпоративных клиентов?
-- по 2 товара
/*
With x AS( 
SELECT 
ca.order_id,
d.cust_id,
count(pr.product_nm) nm_order
FROM sql.store_products pr JOIN sql.store_carts ca ON pr.product_id=ca.product_id
LEFT JOIN sql.store_delivery d ON ca.order_id = d.order_id 	
GROUP BY 1,2
ORDER BY 1,2
)
SELECT
count(x.order_id),
sum(nm_order),
round(avg(nm_order),2)
FROM x JOIN sql.store_customers cu ON x.cust_id = cu.cust_id
WHERE cu.category = 'Corporate'
-- WHERE cu.category = 'Consumer'
ORDER BY 1 ASC */

-- 3. Сколько в среднем различных офисов у корпоративных клиентов?
-- по 6 офисов
/*
With t AS( 
SELECT 
d.cust_id,
count(d.zip_code) code
FROM sql.store_delivery d
JOIN sql.store_customers cu ON cu.cust_id = d.cust_id
WHERE cu.category = 'Corporate'
-- WHERE cu.category = 'Consumer'
Group by 1
ORDER BY 1)

Select
round(avg(code),0)
from t */














