-- Customer Cohort Retention Analysis
-- Demonstrates: multi-step CTEs, DATE_DIFF, cohort logic, self-JOIN

WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', MIN(o.order_purchase_timestamp::TIMESTAMP)) AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
),
customer_orders AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp::TIMESTAMP) AS order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohort_data AS (
    SELECT
        fp.cohort_month,
        DATEDIFF('month', fp.cohort_month, co.order_month) AS months_since_first,
        COUNT(DISTINCT co.customer_unique_id)              AS active_customers
    FROM first_purchase fp
    JOIN customer_orders co ON fp.customer_unique_id = co.customer_unique_id
    GROUP BY 1, 2
),
cohort_sizes AS (
    SELECT cohort_month, active_customers AS cohort_size
    FROM cohort_data
    WHERE months_since_first = 0
)
SELECT
    cd.cohort_month,
    cs.cohort_size,
    cd.months_since_first,
    cd.active_customers,
    ROUND(cd.active_customers * 100.0 / cs.cohort_size, 1) AS retention_pct
FROM cohort_data cd
JOIN cohort_sizes cs ON cd.cohort_month = cs.cohort_month
WHERE cd.cohort_month BETWEEN '2017-01-01' AND '2018-03-01'
  AND cd.months_since_first <= 6
ORDER BY cd.cohort_month, cd.months_since_first;
