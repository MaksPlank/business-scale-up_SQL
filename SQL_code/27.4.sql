-- 27.4.1
-- sql.store_delivery - справочник клиентов: cust_id::varchar / cust_nm::text / category::text
-- sql.store_delivery инф. о заказах и их доставке: 
/*
rder_id::varchar::id заказа, первичный ключ таблицы
order_dat::date::дата заказа
ship_date::date::фактическая дата доставки
ship_mode::text::тип доставки
state::text::штат доставки
city::tex::город доставки
zip_code::tex::индекс доставки
cust_id::varchar::
*/

SELECT *
FROM sql.store_delivery