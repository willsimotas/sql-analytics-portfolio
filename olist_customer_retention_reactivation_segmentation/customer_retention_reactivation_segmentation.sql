/* 
Olist: Customer Retention & Reactivation Segmentation (Segment Summary)

Creates customer segments using:
- Recency: days since last purchase
- Frequency: lifetime order count
- Monetary: lifetime spend

Outputs a segment-level summary:
customers, avg orders, avg spend, total revenue, revenue share
*/

WITH params AS (
  SELECT MAX(order_purchase_timestamp)::date AS as_of_date
  FROM orders
),

orders_clean AS (
  SELECT
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp::date AS purchase_date
  FROM orders o
  WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp IS NOT NULL
),

payments_by_order AS (
  SELECT
    op.order_id,
    SUM(op.payment_value) AS order_revenue
  FROM order_payments op
  GROUP BY op.order_id
),

customer_rollup AS (
  SELECT
    oc.customer_id,
    COUNT(DISTINCT oc.order_id) AS lifetime_orders,
    COALESCE(SUM(pbo.order_revenue), 0) AS lifetime_spend,
    MAX(oc.purchase_date) AS last_purchase_date
  FROM orders_clean oc
  LEFT JOIN payments_by_order pbo
    ON pbo.order_id = oc.order_id
  GROUP BY oc.customer_id
),

customer_features AS (
  SELECT
    cr.customer_id,
    cr.lifetime_orders,
    cr.lifetime_spend,
    cr.last_purchase_date,
    (p.as_of_date - cr.last_purchase_date) AS days_since_last_purchase
  FROM customer_rollup cr
  CROSS JOIN params p
),

segmented AS (
  SELECT
    *,
    CASE
      WHEN lifetime_spend >= 1000 AND days_since_last_purchase <= 60 THEN 'VIP Active'
      WHEN lifetime_spend >= 1000 AND days_since_last_purchase > 60 THEN 'VIP At-Risk'
      WHEN lifetime_orders >= 3 AND days_since_last_purchase <= 90 THEN 'Loyal Active'
      WHEN lifetime_orders >= 3 AND days_since_last_purchase > 90 THEN 'Loyal At-Risk'
      WHEN lifetime_orders = 2 AND days_since_last_purchase <= 90 THEN 'Repeat Recent'
      WHEN lifetime_orders = 2 AND days_since_last_purchase > 90 THEN 'Repeat Lapsed'
      WHEN lifetime_orders = 1 AND days_since_last_purchase <= 60 THEN 'New'
      ELSE 'One-time Lapsed'
    END AS customer_segment
  FROM customer_features
)

SELECT
  customer_segment,
  COUNT(*) AS customers,
  ROUND(AVG(lifetime_orders)::numeric, 2) AS avg_orders,
  ROUND(AVG(lifetime_spend)::numeric, 2) AS avg_spend,
  ROUND(SUM(lifetime_spend)::numeric, 2) AS total_revenue,
  ROUND(
    (SUM(lifetime_spend) / NULLIF((SELECT SUM(lifetime_spend) FROM segmented), 0))::numeric,
    4
  ) AS revenue_share
FROM segmented
GROUP BY customer_segment
ORDER BY total_revenue DESC;
