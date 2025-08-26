CREATE STREAM transactions_input_stream (
    id           BIGINT,
    customer_id  INT,
    amount       DECIMAL(8,2),
    created_at  BIGINT
) WITH (
    KAFKA_TOPIC='transactions',
    VALUE_FORMAT='AVRO',
    TIMESTAMP='created_at'
);

CREATE SOURCE TABLE customers_input_table (
    id         INT PRIMARY KEY,
    first_name STRING,
    last_name  STRING,
    email      STRING,
    gender     STRING
) WITH (
    KAFKA_TOPIC = 'customers',
    VALUE_FORMAT = 'AVRO'
);

CREATE STREAM enriched_transactions AS
SELECT t.id AS id,
       t.customer_id,
       c.first_name AS customer_first_name,
       c.last_name AS customer_last_name,
       t.amount,
       t.created_at
FROM transactions_input_stream t
INNER JOIN customers_input_table c ON t.customer_id = c.id;

CREATE STREAM high_value_transactions AS
SELECT *
FROM enriched_transactions
WHERE amount > 10000
EMIT CHANGES;

CREATE TABLE fast_transactions AS
SELECT customer_id,
       COUNT(*) AS transactions_count
FROM enriched_transactions
WINDOW TUMBLING (SIZE 1 MINUTE)
GROUP BY customer_id
HAVING COUNT(*) > 5
EMIT CHANGES;