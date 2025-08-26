# Product Ranking Example

This project demonstrates how to use ksqlDB to process events in real time and calculate the ranking of best-selling products. For this example, we will create a Stream from an `orders` topic, a Table from a `products` topic, enrich orders with product names, and aggregate sales per product in a 1-minute window.

## Prerequisites

This example assumes you have the following components running:

- Apache Kafka
- ksqlDB Server and CLI
- Schema Registry (if using Avro or other schema-based formats)

A Docker Compose file is provided to set up the necessary services. You can start the services with:

```bash
docker-compose up -d
```

## Creating the necessary topics

This project requires two Kafka topics. You can create them using the following CLI commands:

> ⚠️ Make sure your Kafka broker is running on localhost:9092. Adjust the --bootstrap-server parameter if needed.

```bash
for topic in \
  'orders' \
  'products'; \
  do
    kafka-topics \
    --bootstrap-server localhost:9092 \
    --create \
    --topic $topic \
    --replication-factor 1 \
    --partitions 3;
done
```

## Creating streams and tables

To define the orders stream and the products table, you need to first access the ksqlDB CLI:

```bash
docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
```

You can use the [script.sql](script.sql) file to create the necessary streams and tables. Below is a summary of what will be created:

- **Orders Stream**: represents customer orders, containing order_id, product_id, and quantity.
- **Products Table**: contains product information with product_id as the primary key.
- **Enriched Orders Stream**: joins orders with products to add the product name and price.
- **Product Ranking Table**: aggregates total sales per product within a 1-minute tumbling window.

## Producing sample data

You can publish sample data to Kafka topics using the console producer:

Products

```bash
jq -rc '.[] | "\(.id)=\(.)"' products.json | \
  kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic products \
  --property parse.key=true \
  --property key.separator==
```

Orders

```bash
jq -rc .[] ./orders.json | \
  kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic orders
```

## Querying product ranking

To see the product ranking in real time, run:

```sql
SELECT *
FROM product_ranking
EMIT CHANGES;
```

The output will continuously display the total quantity sold per product, updated every minute.