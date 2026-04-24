-- Seller Performance Segmentation
-- Demonstrates: PERCENTILE_CONT, NTILE, multi-metric ranking, window functions

WITH seller_metrics AS (
    SELECT
        s.seller_id,
        s.seller_state,
        COUNT(DISTINCT o.order_id)             AS total_orders,
        ROUND(SUM(oi.price), 2)                AS total_revenue,
        ROUND(AVG(oi.price), 2)                AS avg_item_price,
        ROUND(AVG(r.review_score), 2)          AS avg_review_score,
        COUNT(DISTINCT oi.product_id)          AS unique_products,
        ROUND(
            AVG(DATEDIFF('day',
                o.order_purchase_timestamp::TIMESTAMP,
                o.order_delivered_customer_date::TIMESTAMP
            )), 1
        )                                      AS avg_delivery_days
    FROM sellers s
    JOIN order_items oi  ON s.seller_id  = oi.seller_id
    JOIN orders o        ON oi.order_id  = o.order_id
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY 1, 2
    HAVING COUNT(DISTINCT o.order_id) >= 10
)
SELECT
    seller_id,
    seller_state,
    total_orders,
    total_revenue,
    avg_item_price,
    avg_review_score,
    avg_delivery_days,
    NTILE(4) OVER (ORDER BY total_revenue DESC)        AS revenue_quartile,
    NTILE(4) OVER (ORDER BY avg_review_score DESC)     AS satisfaction_quartile,
    RANK()   OVER (ORDER BY total_revenue DESC)        AS revenue_rank,
    CASE
        WHEN NTILE(4) OVER (ORDER BY total_revenue DESC) = 1
         AND NTILE(4) OVER (ORDER BY avg_review_score DESC) = 1
        THEN 'Star Seller'
        WHEN NTILE(4) OVER (ORDER BY total_revenue DESC) = 1
        THEN 'High Revenue'
        WHEN NTILE(4) OVER (ORDER BY avg_review_score DESC) = 1
        THEN 'High Satisfaction'
        ELSE 'Standard'
    END                                                AS seller_segment
FROM seller_metrics
ORDER BY total_revenue DESC;
