CREATE TABLE `takehome`.rentals (
	rental_id BIGINT NULL,
	user_id BIGINT NULL,
	order_placed_ts TIMESTAMP NULL,
	product_category varchar(30) NULL,
	product varchar(3) NULL,
	order_canceled_ts TIMESTAMP NULL
)

WITH cte AS
(SELECT DISTINCT product_category, product,
ROW_NUMBER() OVER (PARTITION BY product_category ORDER BY count(product) DESC) rn 
FROM rentals 
WHERE order_canceled_ts IS NULL 
GROUP BY product_category,product)

SELECT product_category, product 
FROM cte 
WHERE rn<=5
	

WITH cte AS
(SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_canceled_ts DESC) rn 
FROM rentals 
WHERE order_canceled_ts IS NOT NULL)

SELECT t1.user_id 
FROM cte t1 JOIN cte t2 
ON t1.user_id=t2.user_id 
AND t1.rn=t2.rn+1 
WHERE t1.user_id in (SELECT user_id FROM cte WHERE rn>=2)
AND abs(DATEDIFF(t1.order_canceled_ts,t2.order_canceled_ts))<30


SELECT rental_id 
FROM rentals
WHERE SUBSTRING(product, 1, 1) != SUBSTRING(product_category, 1, 1)