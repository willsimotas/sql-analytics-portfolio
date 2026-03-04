# Customer Spend Benchmarking by ZIP Code

## Project Overview
This project analyzes customer spending behavior and benchmarks individual customer spend against the average spending within their geographic ZIP code prefix. The goal is to understand how a customer’s purchasing activity compares to others in the same region and identify higher-value customers relative to their local market.

## Business Objective
Identify customers who have made multiple purchases and compare their total spending to the average spend of customers within the same ZIP code prefix. This type of analysis is commonly used for:

- Geographic customer segmentation  
- Regional performance benchmarking  
- Identifying high-value customers within local markets  

## Dataset
This analysis uses a public e-commerce dataset loaded into PostgreSQL. The relevant tables include:

- **customers** – customer identifiers and ZIP code prefixes  
- **orders** – order-level transaction records  
- **order_payments** – payment values associated with each order  

## Analytical Approach
The analysis follows these steps:

1. Join transactional tables to connect customers, orders, and payment data.
2. Aggregate total spend per customer using payment values.
3. Count the number of orders per customer to identify repeat purchasers.
4. Calculate the average customer spend within each ZIP code prefix using a window function.
5. Benchmark each customer's spend against their ZIP-level average.

## SQL Concepts Demonstrated

- Table joins across relational datasets
- Aggregations using `SUM()` and `COUNT()`
- Window functions with `AVG() OVER (PARTITION BY ...)`
- Data type casting for formatting results
- Customer-level grouping and geographic benchmarking

## Example Output
The final dataset includes:

- `customer_id`
- `customer_spend`
- `customer_zip_code_prefix`
- `avg_spend_per_zipcode`
- `count_orders_per_customer`

Each row represents a customer and shows how their spending compares to the average spending within their ZIP code region.

## Potential Extensions
Future analysis could expand this project by:

- Identifying customers who significantly outperform their ZIP average
- Creating geographic customer value tiers
- Analyzing changes in spending behavior over time
- Adding recency and lifetime value segmentation
