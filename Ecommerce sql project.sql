use olist_ecommerce;


SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';


SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;



LOAD DATA LOCAL INFILE 'C:/Users/Dell/OneDrive/Desktop/Ecommerce project file/olist_customers_dataset.csv'
INTO TABLE olist_customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


select count(*) from olist_customers;


LOAD DATA LOCAL INFILE 'C:/Users/Dell/OneDrive/Desktop/Ecommerce project file/oilst_geolocation_datase.csv'
INTO TABLE olist_geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


select count(*) from olist_geolocation;


LOAD DATA LOCAL INFILE 'C:/Users/Dell/OneDrive/Desktop/Ecommerce project file/olist_order_items_dataset.csv'
INTO TABLE olist_order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from olist_order_items;



LOAD DATA LOCAL INFILE 'C:/Users/Dell/OneDrive/Desktop/Ecommerce project file/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from olist_order_payments;


LOAD DATA LOCAL INFILE 'C:/Users/Dell/OneDrive/Desktop/Ecommerce project file/olist_order_reviews_dataset 12.csv'
INTO TABLE olist_order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from olist_order_reviews;


LOAD DATA LOCAL INFILE 'C:/Users/Dell/OneDrive/Desktop/Ecommerce project file/olist_orders_dataset.csv'
INTO TABLE olist_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from olist_orders;




LOAD DATA LOCAL INFILE 'C:/Users/Dell/OneDrive/Desktop/Ecommerce project file/olist_orders_staging_dataset.csv'
INTO TABLE olist_orders_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from olist_orders_staging;

LOAD DATA LOCAL INFILE 'C:/Users/Dell/OneDrive/Desktop/Ecommerce project file/olist_products_dataset.csv'
INTO TABLE olist_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from olist_products;


LOAD DATA LOCAL INFILE 'C:/Users/Dell/OneDrive/Desktop/Ecommerce project file/olist_sellers_dataset.csv'
INTO TABLE olist_sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from 




LOAD DATA LOCAL INFILE 'C:/Users/Dell/OneDrive/Desktop/Ecommerce project file/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from product_category_name_translation;



ALTER DATABASE olist_ecommerce 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;


ALTER TABLE olist_orders          CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE olist_customers       CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE olist_order_items     CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE olist_order_payments  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE olist_order_reviews   CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE olist_products        CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE olist_sellers         CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE olist_geolocation     CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE olist_orders_staging  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE product_category_name_translation CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


SELECT 
    table_name,          
    table_collation
FROM information_schema.tables
WHERE table_schema = 'olist_ecommerce';

    

    -- ── Q1  Weekday vs Weekend Payment Statistics ────────────────
-- (based on order_purchase_timestamp)


  -- Q1: Weekday vs Weekend 
SELECT
    CASE
        WHEN DAYOFWEEK(o.order_purchase_timestamp) IN (1, 7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END                                                      AS day_type,
    CONCAT(ROUND(COUNT(o.order_id) / 1000, 1), ' K')        AS total_orders,
    CONCAT(ROUND(SUM(p.payment_value) / 1000000, 2), ' M')  AS total_payment,
    ROUND(AVG(p.payment_value), 2)                           AS avg_payment
FROM olist_orders o
JOIN olist_order_payments p ON o.order_id = p.order_id
GROUP BY 1;
  
  
  
  -- Q2: Number of Orders with Review Score 5
--     AND Payment Type = Credit Card
-- ──────────────────────────────────────────────────────────────

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders          o
JOIN olist_order_reviews   r ON o.order_id = r.order_id
JOIN olist_order_payments  p ON o.order_id = p.order_id
WHERE r.review_score = 5
  AND p.payment_type = 'credit_card';



-- ──────────────────────────────────────────────────────────────
-- Q3: Average Number of Days Taken for
--     order_delivered_customer_date for pet_shop Category
-- ──────────────────────────────────────────────────────────────

SELECT
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp
    )), 2) AS avg_delivery_days
FROM olist_orders      o
JOIN olist_order_items oi ON o.order_id    = oi.order_id
JOIN olist_products    p  ON oi.product_id = p.product_id
WHERE p.product_category_name = 'pet_shop'
  AND o.order_delivered_customer_date IS NOT NULL;


-- ──────────────────────────────────────────────────────────────
-- Q4: Average Price and Payment Values
--     from Customers of Sao Paulo City
-- ──────────────────────────────────────────────────────────────
SELECT
    ROUND(AVG(p.payment_value), 2) AS avg_payment
FROM olist_customers       c
JOIN olist_orders          o  ON c.customer_id = o.customer_id
JOIN olist_order_payments  p  ON o.order_id    = p.order_id
WHERE c.customer_city = 'sao paulo';


-- ──────────────────────────────────────────────────────────────
-- Q5: Relationship Between Shipping Days
--     (order_delivered_customer_date - order_purchase_timestamp)
--     vs Review Scores
-- ──────────────────────────────────────────────────────────────
SELECT
    r.review_score,
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp
    )), 2) AS avg_shipping_days
FROM olist_orders          o
JOIN olist_order_reviews   r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;


-- ──────────────────────────────────────────────────────────────
-- Q6: Shipping Range Buckets vs Average Review Score
-- ──────────────────────────────────────────────────────────────
SELECT
    CASE
        WHEN DATEDIFF(o.order_delivered_customer_date,
                      o.order_purchase_timestamp) BETWEEN 1  AND 10  THEN '1-10 Days'
        WHEN DATEDIFF(o.order_delivered_customer_date,
                      o.order_purchase_timestamp) BETWEEN 11 AND 20  THEN '11-20 Days'
        WHEN DATEDIFF(o.order_delivered_customer_date,
                      o.order_purchase_timestamp) BETWEEN 21 AND 30  THEN '21-30 Days'
        WHEN DATEDIFF(o.order_delivered_customer_date,
                      o.order_purchase_timestamp) BETWEEN 31 AND 60  THEN '31-60 Days'
        WHEN DATEDIFF(o.order_delivered_customer_date,
                      o.order_purchase_timestamp) BETWEEN 61 AND 120 THEN '61-120 Days'
        ELSE '120+ Days'
    END                              AS shipping_range,
    ROUND(AVG(r.review_score), 2)    AS avg_review_score
FROM olist_orders                    o
JOIN olist_order_reviews             r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY
    CASE shipping_range
        WHEN '1-10 Days'   THEN 1
        WHEN '11-20 Days'  THEN 2
        WHEN '21-30 Days'  THEN 3
        WHEN '31-60 Days'  THEN 4
        WHEN '61-120 Days' THEN 5
        ELSE 6
    END;


-- ──────────────────────────────────────────────────────────────
-- Q7: Total Number of Orders (Overall Count)
-- ──────────────────────────────────────────────────────────────
SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders;


-- ──────────────────────────────────────────────────────────────
-- Q8: Total Revenue
-- ──────────────────────────────────────────────────────────────

SELECT
    CONCAT(ROUND(SUM(payment_value) / 1000000, 2), ' M') AS total_revenue
FROM olist_order_payments;




-- Q8: Total Revenue 
SELECT
    CONCAT(ROUND(SUM(payment_value) / 1000000, 2), ' M') AS total_revenue
FROM olist_order_payments;


-- ──────────────────────────────────────────────────────────────
-- Q9: Monthly Revenue Trend
-- ──────────────────────────────────────────────────────────────

SELECT
    YEAR(o.order_purchase_timestamp)      AS order_year,
    MONTH(o.order_purchase_timestamp)     AS order_month,
    MONTHNAME(o.order_purchase_timestamp) AS month_name,
    COUNT(DISTINCT o.order_id)            AS total_orders,
    ROUND(SUM(p.payment_value), 2)        AS total_revenue,
    ROUND(AVG(p.payment_value), 2)        AS avg_order_value
FROM olist_orders          o
JOIN olist_order_payments  p ON o.order_id = p.order_id
GROUP BY 1, 2, 3
ORDER BY 1, 2;


-- ──────────────────────────────────────────────────────────────
-- Q10: Payment Type Distribution
-- ──────────────────────────────────────────────────────────────
SELECT
    payment_type,
    COUNT(*)                          AS total_transactions,
    ROUND(SUM(payment_value), 2)      AS total_revenue,
    ROUND(AVG(payment_value), 2)      AS avg_payment,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2)      AS percentage
FROM olist_order_payments
GROUP BY payment_type
ORDER BY total_transactions DESC;


-- ──────────────────────────────────────────────────────────────
-- Q11: Top 10 Cities by Number of Orders
-- ──────────────────────────────────────────────────────────────
SELECT
    c.customer_city,
    COUNT(DISTINCT o.order_id)        AS total_orders,
    ROUND(SUM(p.payment_value), 2)    AS total_revenue
FROM olist_customers       c
JOIN olist_orders          o ON c.customer_id = o.customer_id
JOIN olist_order_payments  p ON o.order_id    = p.order_id
GROUP BY c.customer_city
ORDER BY total_orders DESC
LIMIT 10;


-- ──────────────────────────────────────────────────────────────
-- Q12: Top 10 Product Categories by Orders
-- ──────────────────────────────────────────────────────────────
SELECT
    t.product_category_name_english   AS category,
    COUNT(DISTINCT o.order_id)        AS total_orders,
    ROUND(SUM(p.payment_value), 2)    AS total_revenue,
    ROUND(AVG(p.payment_value), 2)    AS avg_payment
FROM olist_orders                     o
JOIN olist_order_items                oi ON o.order_id    = oi.order_id
JOIN olist_products                   pr ON oi.product_id = pr.product_id
JOIN product_category_name_translation t ON pr.product_category_name = t.product_category_name
JOIN olist_order_payments             p  ON o.order_id    = p.order_id
GROUP BY t.product_category_name_english
ORDER BY total_orders DESC
LIMIT 10;


-- ──────────────────────────────────────────────────────────────
-- Q13: Order Status Distribution
-- ──────────────────────────────────────────────────────────────
SELECT
    order_status,
    COUNT(*)                          AS total_orders,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2)      AS percentage
FROM olist_orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- ──────────────────────────────────────────────────────────────
-- Q14: Average Review Score by Product Category
-- ──────────────────────────────────────────────────────────────
SELECT
    t.product_category_name_english   AS category,
    ROUND(AVG(r.review_score), 2)     AS avg_review_score,
    COUNT(DISTINCT o.order_id)        AS total_orders
FROM olist_orders                     o
JOIN olist_order_reviews              r  ON o.order_id    = r.order_id
JOIN olist_order_items                oi ON o.order_id    = oi.order_id
JOIN olist_products                   pr ON oi.product_id = pr.product_id
JOIN product_category_name_translation t ON pr.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY avg_review_score DESC
LIMIT 10;


-- ──────────────────────────────────────────────────────────────
-- Q15: Top 10 Sellers by Total Orders
-- ──────────────────────────────────────────────────────────────
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)       AS total_orders,
    ROUND(SUM(oi.freight_value), 2)   AS total_freight,
    ROUND(AVG(r.review_score), 2)     AS avg_review_score
FROM olist_sellers                    s
JOIN olist_order_items                oi ON s.seller_id  = oi.seller_id
JOIN olist_order_reviews              r  ON oi.order_id  = r.order_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_orders DESC
LIMIT 10;


-- ──────────────────────────────────────────────────────────────
-- Q16: Review Score Distribution with Percentage
-- ──────────────────────────────────────────────────────────────
SELECT
    review_score,
    COUNT(*)                          AS total_reviews,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2)      AS percentage
FROM olist_order_reviews
GROUP BY review_score
ORDER BY review_score;


-- ──────────────────────────────────────────────────────────────
-- Q17: Average Freight Value by Seller State
-- ──────────────────────────────────────────────────────────────
SELECT
    s.seller_state,
    COUNT(DISTINCT oi.order_id)       AS total_orders,
    ROUND(AVG(oi.freight_value), 2)   AS avg_freight_value,
    ROUND(SUM(oi.freight_value), 2)   AS total_freight_value
FROM olist_sellers     s
JOIN olist_order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY total_orders DESC;


-- ──────────────────────────────────────────────────────────────
-- Q18: Orders Delivered Late
--      (delivered after estimated delivery date)
-- ──────────────────────────────────────────────────────────────
SELECT
    COUNT(*) AS late_deliveries,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(*) FROM olist_orders
        WHERE order_delivered_customer_date IS NOT NULL
    ), 2)    AS late_percentage
FROM olist_orders
WHERE order_delivered_customer_date > order_estimated_delivery_date
  AND order_delivered_customer_date IS NOT NULL;






