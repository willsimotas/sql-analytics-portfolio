/*
Project: Customer Spend Benchmarking by ZIP Code

Business Objective:
Benchmark each customer's total spend against the average customer spend within the
same ZIP code prefix. Filter to repeat customers (more than 1 order).

Approach:
1) Join customers → orders → order_payments to connect customers with payment data.
2) Aggregate total spend and order count at the customer level.
3) Compute average customer spend by ZIP code prefix using a window function.
4) Return customer spend, ZIP benchmark, and order count for comparison.
*/

WITH customer_level AS (
  SELECT
    c.customer_id,
    c.customer_zip_code_prefix,
    SUM(op.payment_value) AS customer_spend,
    COUNT(DISTINCT o.order_id) AS order_count
  FROM customers c
  JOIN orders o
    ON c.customer_id = o.customer_id
  JOIN order_payments op
    ON op.order_id = o.order_id
  GROUP BY
    c.customer_id,
    c.customer_zip_code_prefix
)

SELECT
  customer_id,
  customer_zip_code_prefix,
  customer_spend,
  TO_CHAR(customer_spend, 'FM$999,999,999,999.00') AS customer_spend_display,
  AVG(customer_spend) OVER (PARTITION BY customer_zip_code_prefix) AS avg_spend_per_zipcode,
  TO_CHAR(
    AVG(customer_spend) OVER (PARTITION BY customer_zip_code_prefix),
    'FM$999,999,999,999.00'
  ) AS avg_spend_per_zipcode_display,
  order_count
FROM customer_level
WHERE order_count > 1
ORDER BY avg_spend_per_zipcode DESC, customer_spend DESC;
