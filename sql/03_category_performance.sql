-- Product Category Performance Ranking
-- Demonstrates: multi-table JOIN (5 tables), RANK, NTILE, conditional aggregation

WITH category_stats AS (
    SELECT
        COALESCE(cat.product_category_name_english, p.product_category_name, 'Unknown') AS category,
        COUNT(DISTINCT o.order_id)                              AS total_orders,
        COUNT(DISTINCT oi.product_id)                          AS unique_products,
        ROUND(SUM(oi.price), 2)                                AS total_revenue,
        ROUND(AVG(oi.price), 2)                                AS avg_price,
        ROUND(AVG(r.review_score), 2)                          AS avg_review_score,
        COUNT(CASE WHEN r.review_score >= 4 THEN 1 END) * 100.0
            / NULLIF(COUNT(r.review_score), 0)                 AS pct_positive_reviews
    FROM order_items oi
    JOIN orders o       ON oi.order_id   = o.order_id
    JOIN products p     ON oi.product_id = p.product_id
    LEFT JOIN categories cat ON p.product_category_name = cat.product_category_name
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT
    category,
    total_orders,
    unique_products,
    total_revenue,
    avg_price,
    avg_review_score,
    ROUND(pct_positive_reviews, 1)              AS pct_positive_reviews,
    RANK() OVER (ORDER BY total_revenue DESC)   AS revenue_rank,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile
FROM category_stats
WHERE total_orders >= 50
ORDER BY total_revenue DESC
LIMIT 20;
