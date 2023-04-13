--case study 7
SET search_path = case_study_7;


SELECT * FROM product_details;
SELECT * FROM product_hierarchy;
SELECT * FROM product_prices;
SELECT * FROM sales LIMIT 100;

-- 1. High Level Sales Analysis
-- 1 What was the total quantity sold for all products?
SELECT
	prod_id,
	product_name,
	SUM(qty) AS "total_qty"
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY prod_id,product_name
ORDER BY prod_id,product_name;

--answer
SELECT
	SUM(qty) AS "total_sale_qty"
FROM sales;

-- 2 What is the total generated revenue for all products before discounts?
SELECT 
	SUM(qty*price) AS "total_revenue"
FROM sales;

-- 3 What was the total discount amount for all products?
SELECT
	SUM(price*qty*discount*0.01) AS "total_discount"
FROM sales;



-- 2. Transaction Analysis
-- 1 How many unique transactions were there?
SELECT
	COUNT(DISTINCT txn_id) AS "unique_txn"
FROM sales;

-- 2 What is the average unique products purchased in each transaction?
WITH cte AS
(	SELECT
		txn_id,
		COUNT(DISTINCT prod_id) AS "cnt"
	FROM sales
	GROUP BY txn_id)
SELECT
	ROUND(AVG(cnt))
FROM cte;

-- 3 What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH cte AS
(	SELECT
		txn_id,
		SUM((qty*price)-(price*qty*discount*0.01)) AS "sale"
 	FROM sales
 	GROUP BY txn_id)
SELECT
	PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY sale) AS "25th_percent",
	PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY sale) AS "50th_percent",
	PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY sale) AS "75th_percent"
from cte;

-- 4 What is the average discount value per transaction?
WITH cte AS
(	SELECT
		txn_id,
		SUM(price*qty*discount*0.01) AS "dis_per_txn"
	FROM sales
	GROUP BY txn_id)
SELECT
	ROUND(AVG(dis_per_txn),2)
FROM cte;

-- 5 What is the percentage split of all transactions for members vs non-members?
SELECT 
	CASE
		WHEN member THEN 'member'
		ELSE 'non_member'
	END AS "membership",
	ROUND((COUNT(*)*100.0) / (SELECT COUNT(*) FROM sales),2)||' %' AS "percent_split"
FROM sales
GROUP BY member;

-- 6 What is the average revenue for member transactions and non-member transactions?
WITH cte AS
(	SELECT
 		CASE
 			WHEN member THEN 'member'
 			ELSE 'non-member'
 		END AS "membership",
  		txn_id,
 		SUM(price*qty - (price*qty*discount*0.01)) AS "rev"
 	FROM sales
 	GROUP BY member,txn_id)
SELECT
	membership,
	ROUND(AVG(rev),2) AS "avg_rev_member"
FROM cte
GROUP BY membership;



-- 3.Product Analysis
-- 1 What are the top 3 products by total revenue before discount?
SELECT
	prod_id,
	product_name,
	SUM(s.price*qty) AS "rev"
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY prod_id,product_name
ORDER BY rev DESC
LIMIT 3;

-- 2 What is the total quantity, revenue and discount for each segment?
SELECT 
	segment_name,
	SUM(qty) AS "quantity",
	SUM(s.price*qty-(s.price*qty*discount*0.01)) AS "revenue",
	SUM(s.price*qty*discount*0.01) AS "discount"
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY segment_name;

-- 3 What is the top selling product for each segment?
WITH cte AS
(	SELECT
		segment_name,
		product_name,
		SUM(qty) AS "sold_quant"
	FROM product_details pd
	JOIN sales s
	ON pd.product_id = s.prod_id
	GROUP BY segment_name,product_name)
SELECT
	DISTINCT ON(segment_name)
	segment_name,
	sold_quant,
	FIRST_VALUE(product_name) OVER(PARTITION BY segment_name
								  ORDER BY sold_quant DESC)
FROM cte;

-- 4 What is the total quantity, revenue and discount for each category?
SELECT
	category_name,
	SUM(qty) AS "total_quantity",
	SUM((s.price*qty)-(s.price*qty*discount*0.01)) AS "total_revenue",
	SUM(s.price*qty*discount*0.01) AS "total_discount"
FROM product_details pd
JOIN sales s
ON pd.product_id=s.prod_id
GROUP BY category_name;

-- 5 What is the top selling product for each category?
WITH cte AS
(	SELECT
		category_name,
		product_name,
		SUM(qty) AS "sold_quant"
	FROM product_details pd
	JOIN sales s
	ON pd.product_id = s.prod_id
	GROUP BY category_name,product_name)
SELECT
	DISTINCT ON(category_name)
	category_name,
	product_name,
	sold_quant,
	FIRST_VALUE(product_name) OVER(PARTITION BY category_name
								  ORDER BY sold_quant DESC)
FROM cte;

-- 6 What is the percentage split of revenue by product for each segment?

-- 7 What is the percentage split of revenue by segment for each category?

-- 8 What is the percentage split of total revenue by category?

-- 9 What is the total transaction “penetration” for each product? 
--   (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

-- 10 What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
