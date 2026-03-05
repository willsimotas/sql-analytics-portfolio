/* 
Project: Olist Customer Retention & Reactivation Analysis

Goal:
Identify high-value customers and measure their recent purchasing activity.

Metrics created:
- Lifetime customer spend
- Orders in the last 100 days
- Most recent purchase date

Dataset:
Olist Brazilian E-commerce Dataset
Tables used:
- orders
- order_payments
*/

-- Step 1: Calculate lifetime spend per customer
WITH lifetime AS (
    SELECT
        o.customer_id,
        SUM(op.payment_value) AS lifetime_spend
    FROM orders o
    JOIN order_payments op
        ON op.order_id = o.order_id
    GROUP BY o.customer_id
),

-- Step 2: Measure recent activity
recent AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS orders_last_100_days,
        MAX(order_purchase_timestamp) AS last_purchase_date
    FROM orders
    WHERE order_purchase_timestamp >=
        (SELECT MAX(order_purchase_timestamp) FROM orders) - INTERVAL '100 days'
    GROUP BY customer_id
)

-- Step 3: Combine metrics and filter high-value customers
SELECT
    l.customer_id,
    l.lifetime_spend,
    r.orders_last_100_days,
    r.last_purchase_date
FROM lifetime l
JOIN recent r
    ON r.customer_id = l.customer_id
WHERE l.lifetime_spend > 1000
ORDER BY l.lifetime_spend DESC;
