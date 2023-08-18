/*
sql.store_customers cu КЛИЕНТЫ 
    ** cu.cust_id     ::varchar   / id клиента <<<
	-- cu.cust_nm     ::text      / имя клиента
	-- cu.category    ::text      / 'Consumer' B2C-клиент / 'Corporate' B2B-клиент 
	
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
	** d.order_id     ::varchar  / id заказа 
	<< d.cust_id      ::varchar  / id клиента  / 4100 : B2B / 
	-- d.order_date   ::date     / дата заказа
	-- d.ship_date    ::date     / фактическая дата доставки
	-- d.ship_mode    ::text     / тип доставки
	-- d.state        ::text     / штат доставки
	-- d.city         ::tex      / город доставки
	-- d.zip_code     ::tex      / индекс доставки */
-------------------------------------------------------------------------------------

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
-------------------------------------------------------------------------------------


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

-------------------------------------------------------------------------------------


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



