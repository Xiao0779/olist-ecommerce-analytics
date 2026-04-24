-- Monthly Revenue Trends with MoM Growth
-- Demonstrates: DATE_TRUNC, window functions (LAG), CTEs

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp::TIMESTAMP) AS month,
        COUNT(DISTINCT o.order_id)                                  AS total_orders,
        ROUND(SUM(oi.price + oi.freight_value), 2)                 AS revenue,
        ROUND(AVG(oi.price), 2)                                     AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY 1
)
SELECT
    month,
    total_orders,
    revenue,
    avg_order_value,
    LAG(revenue) OVER (ORDER BY month)                             AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 1
    )                                                              AS mom_growth_pct,
    ROUND(SUM(revenue) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING), 2) AS cumulative_revenue
FROM monthly_revenue
ORDER BY month;
