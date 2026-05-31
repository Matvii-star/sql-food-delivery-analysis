--row count
SELECT COUNT(*)
FROM food_orders;

--missing values
SELECT
COUNT(*) FILTER(WHERE payment_method is NULL) as payment_method,
COUNT(*) FILTER(WHERE order_value is NULL) as order_value,
COUNT(*) FILTER(WHERE customer_id is NULL) as customer_id,
COUNT(*) FILTER(WHERE restaurant_id is NULL) as restaurant_id,
COUNT(*) FILTER(WHERE order_datetime is NULL) as order_datetime,
COUNT(*) FILTER(WHERE delivery_datetime is NULL) as delivery_datetime,
COUNT(*) FILTER(WHERE delivery_fee is NULL) as delivery_fee,
COUNT(*) FILTER(WHERE discounts_offers is NULL) as discounts_offers,
COUNT(*) FILTER(WHERE commission_fee is NULL) as commission_fee,
COUNT(*) FILTER(WHERE payment_processing_fee is NULL) as payment_processing_fee,
COUNT(*) FILTER(WHERE refunds_chargebacks is NULL) as refunds_chargebacks
FROM food_orders;

--duplicates
SELECT
order_id, COUNT(*)
FROM food_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--total revenue
SELECT
SUM(order_value) AS total_revenue
FROM food_orders;

--top restaurants
WITH restaurant_revenue AS (
    SELECT
        restaurant_id,
        SUM(order_value) AS revenue, COUNT(*) AS "Count orders"
    FROM food_orders
    GROUP BY restaurant_id
)

SELECT
    restaurant_id,
    revenue,
    ROUND(
        revenue * 100.0 /
        (SELECT SUM(revenue) FROM restaurant_revenue),
        2
    ) AS revenue_share, "Count orders"
FROM restaurant_revenue
ORDER BY revenue DESC
LIMIT 10;

--average order value
SELECT ROUND(AVG(order_value),2) AS Average_order
FROM food_orders;

--average order value by restaurant
SELECT restaurant_id, ROUND(AVG(order_value),2) AS Average_order, count(*)
FROM food_orders
GROUP BY restaurant_id
HAVING count(*)>1
ORDER BY Average_order DESC
Limit 10;

--average delivery time
SELECT AVG(EXTRACT(EPOCH FROM (delivery_datetime - order_datetime))::int / 60) as Delivery_time_min
FROM food_orders;

--slowest restaurants
SELECT restaurant_id,count(*), AVG(EXTRACT(EPOCH FROM (delivery_datetime - order_datetime))::int / 60) as Delivery_time_min
FROM food_orders
GROUP BY restaurant_id
HAVING count(*)>1
ORDER BY Delivery_time_min DESC
LIMIT 10;


--payment distribution
SELECT
    payment_method,
    COUNT(*) AS orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM food_orders
GROUP BY payment_method
ORDER BY orders DESC;	

--revenue by payment method
SELECT 
	payment_method, 
	SUM(order_value) as Total_revenue,  
	ROUND(AVG(order_value),2) AS avg_order_value
FROM food_orders
GROUP BY payment_method
ORDER BY Total_revenue DESC;

--discount usage
SELECT discounts_offers, count(*) as orders, Round(avg(order_value),2) as avg_order_value
FROM food_orders
GROUP BY discounts_offers
Order by orders desc;
 
--impact on average order value
SELECT
CASE
WHEN discounts_offers ='None' THEN 'No discount'
ELSE 'Discount'
END AS discount_group, COUNT(*), Round(avg(order_value),2)
FROM food_orders
GROUP BY discount_group;

--total refunds
SELECT
    COUNT(*) FILTER (
        WHERE refunds_chargebacks > 0
    ) AS refunded_orders,
    SUM(refunds_chargebacks) AS total_refunds
FROM food_orders;

--restaurants with most refunds
SELECT restaurant_id,
COUNT(refunds_chargebacks) FILTER(WHERE refunds_chargebacks > 0) as refunds,
SUM(refunds_chargebacks) as total_refunds
FROM food_orders
GROUP BY restaurant_id
HAVING COUNT(refunds_chargebacks) FILTER(WHERE refunds_chargebacks > 0) > 0
Order by SUM(refunds_chargebacks) DESC;