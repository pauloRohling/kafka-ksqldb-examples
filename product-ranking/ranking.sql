CREATE STREAM orders_input_stream (
    order_id STRING,
    product_id STRING,
    quantity INT
) WITH (
    KAFKA_TOPIC='orders',
    VALUE_FORMAT='JSON'
);

CREATE SOURCE TABLE products_input_table (
    id STRING PRIMARY KEY,
    name STRING,
    price DECIMAL(10, 2)
) WITH (
    KAFKA_TOPIC='products',
    VALUE_FORMAT='JSON'
);

CREATE STREAM enriched_orders AS
SELECT o.order_id,
       p.id AS product_id,
       p.name AS product_name,
       o.quantity,
       (p.price * o.quantity) AS total
FROM orders_input_stream o
INNER JOIN products_input_table p ON o.product_id = p.id;

CREATE TABLE product_ranking_1min AS
SELECT product_name,
       SUM(quantity) AS total_sold,
       SUM(total) AS total
FROM enriched_orders
WINDOW TUMBLING (SIZE 1 MINUTE)
GROUP BY product_name
EMIT CHANGES;
