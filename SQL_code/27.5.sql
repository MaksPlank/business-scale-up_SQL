/*
sql.store_customers cu КЛИЕНТЫ 
	>> cu.cust_id   ::varchar   / id клиента <<<
	-- cu.cust_nm   ::text      / имя клиента
	-- cu.category  ::text      / 'Consumer' (B2C-клиент,розничный пок.), 'Corporate' (B2B-клиент,компания)
	
sql.store_products pr ТОВАР 
	>> pr.product_id  ::varchar / id товара <<
	-- pr.category    ::text    / категория товара
	-- pr.subcategory ::text    / подкатегория товара
	-- pr.product_nm  ::text    / название, свойства: цвет, модель, бренд итд
	-- pr.price       ::numeric / цена товара
	
sql.store_carts ca ТОВАР  //  d.order_id = ca.order_id  /  pr.product_id = ca.product_id
	<< ca.order_id    ::varchar / id заказа >>> store_delivery
	<< ca.product_id  ::varchar / id товара >>> store_products
	-- ca.id          ::integer / id записи в таблице
	-- ca.quantity    ::integer / кол-во единиц отдельного товара в заказе
	-- ca.discount    ::numeric / доля скидки на определённый товар; 0.1 = 10% 
	
sql.store_delivery d ЗАКАЗЫ и ДОСТАВКА // d.order_id = ca.order_id / cu.cust_id = d.cust_id
	>> d.order_id     ::varchar / id заказа <<
	<< d.cust_id      ::varchar / id клиента >>> store_customers
	-- d.order_date   ::date    / дата заказа
	-- d.ship_date    ::date    / фактическая дата доставки
	-- d.ship_mode    ::text    / тип доставки
	-- d.state        ::text    / штат доставки
	-- d.city         ::tex     / город доставки
	-- d.zip_code     ::tex     / индекс доставки */
	



-- 27.4.1
-- Заказы по предоставленным данным 'осуществлялись' с 03/01/2017 по 30/12/2020гг
/* 
SELECT 
max(order_date), -- 2020-12-30
min(order_date) -- 2017-01-03
FROM sql.store_delivery */


-- 27.4.2
-- Всего 5009 заказов было выполнено за данный период
/*
SELECT 
count(order_date) -- 5009
FROM sql.store_delivery */


-- 27.4.3
-- Объём общей выручки = 1 446 157 руб.
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


-- 27.5.1
-- Cумма выручки по месяцам:
/*
"2017-01-01"	9394
"2017-02-01"	3040
"2017-03-01"	33638
"2017-04-01"	20108
"2017-05-01"	13784
"2017-06-01"	21739
"2017-07-01"	23720
"2017-08-01"	17536
"2017-09-01"	45852
"2017-10-01"	22021
"2017-11-01"	48931
"2017-12-01"	41632
"2018-01-01"	11088
"2018-02-01"	7400
"2018-03-01"	21547
"2018-04-01"	18971
"2018-05-01"	19253
"2018-06-01"	14764
"2018-07-01"	19969
"2018-08-01"	23499
"2018-09-01"	41462
"2018-10-01"	21726
"2018-11-01"	52948
"2018-12-01"	45949
"2019-01-01"	12141
"2019-02-01"	14067
"2019-03-01"	36057
"2019-04-01"	28246
"2019-05-01"	36745
"2019-06-01"	26777
"2019-07-01"	25959
"2019-08-01"	20535
"2019-09-01"	41531
"2019-10-01"	36558
"2019-11-01"	52114
"2019-12-01"	57208
"2020-01-01"	25729
"2020-02-01"	13416
"2020-03-01"	37962
"2020-04-01"	20114
"2020-05-01"	28979
"2020-06-01"	35985
"2020-07-01"	27247
"2020-08-01"	37409
"2020-09-01"	55987
"2020-10-01"	48273
"2020-11-01"	74906
"2020-12-01"	52241

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


-- 27.5.5
-- Сумма выручки по различным категориям и подкатегориям:
/*
"Furniture"	"Chairs"	235318
"Technology"	"Phones"	221110
"Office Supplies"	"Storage"	179736
"Technology"	"Accessories"	125442
"Furniture"	"Tables"	114532
"Technology"	"Machines"	113978
"Technology"	"Copiers"	95844
"Office Supplies"	"Paper"	62148
"Furniture"	"Bookcases"	59271
"Office Supplies"	"Appliances"	55550
"Furniture"	"Furnishings"	51695
"Office Supplies"	"Binders"	45312
"Office Supplies"	"Supplies"	37457
"Office Supplies"	"Art"	22148
"Office Supplies"	"Envelopes"	13809
"Office Supplies"	"Labels"	10345
"Office Supplies"	"Fasteners"	2459 

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


-- 27.5.6
-- топ-25 товаров по объёму выручки: 


/*
With x AS(   
SELECT
count(pr.product_nm),
SUM(CASE
WHEN ca.discount = 0 THEN (pr.price*ca.quantity) 
ELSE (pr.price*ca.quantity*(1-ca.discount)) END) total_revenue -- 1446157
FROM sql.store_products pr 
JOIN sql.store_carts ca ON pr.product_id=ca.product_id
), 
*/

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






