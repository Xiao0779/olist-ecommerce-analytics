-- Delivery Delay Impact on Review Scores
-- Demonstrates: CASE WHEN bucketing, DATEDIFF, GROUP BY analysis

WITH delivery_analysis AS (
    SELECT
        o.order_id,
        DATEDIFF('day',
            o.order_purchase_timestamp::TIMESTAMP,
            o.order_delivered_customer_date::TIMESTAMP
        )                                                       AS actual_delivery_days,
        DATEDIFF('day',
            o.order_purchase_timestamp::TIMESTAMP,
            o.order_estimated_delivery_date::TIMESTAMP
        )                                                       AS estimated_delivery_days,
        DATEDIFF('day',
            o.order_estimated_delivery_date::TIMESTAMP,
            o.order_delivered_customer_date::TIMESTAMP
        )                                                       AS days_vs_estimate,
        r.review_score
    FROM orders o
    JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    CASE
        WHEN days_vs_estimate <= -7 THEN 'Early (7+ days)'
        WHEN days_vs_estimate <= -1 THEN 'Early (1-6 days)'
        WHEN days_vs_estimate = 0   THEN 'On Time'
        WHEN days_vs_estimate <= 7  THEN 'Late (1-7 days)'
        ELSE                             'Late (7+ days)'
    END                                             AS delivery_category,
    CASE
        WHEN days_vs_estimate <= -7 THEN 1
        WHEN days_vs_estimate <= -1 THEN 2
        WHEN days_vs_estimate = 0   THEN 3
        WHEN days_vs_estimate <= 7  THEN 4
        ELSE                             5
    END                                             AS sort_order,
    COUNT(*)                                        AS order_count,
    ROUND(AVG(review_score), 2)                     AS avg_review_score,
    ROUND(AVG(actual_delivery_days), 1)             AS avg_actual_days,
    COUNT(CASE WHEN review_score >= 4 THEN 1 END) * 100.0
        / COUNT(*)                                  AS pct_satisfied
FROM delivery_analysis
GROUP BY 1, 2
ORDER BY 2;
