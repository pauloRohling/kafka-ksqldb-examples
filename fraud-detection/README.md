# Fraud Detection Example

This project demonstrates how to use ksqlDB to detect suspicious financial transactions in real time. The example showcases filtering, joins, and windowed aggregations to identify potential fraud patterns.

## Prerequisites

This example assumes you have the following components running:

- Apache Kafka
- ksqlDB Server and CLI
- Kafka Connect
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
  'customers' \
  'transactions'; \
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

The ksqlDB statements for this example are defined in the [script.sql](script.sql) file. The script performs the following operations:

- **Transactions Stream**: represents incoming financial transactions.
- **Customers Table**: represents customer reference data, keyed by id.
- **Enriched Transactions Stream**: joins transactions with customer information.
- **High-Value Transactions Stream**: filters transactions above a configurable threshold (> 10,000).
- **Fast Transactions Table**: detects customers with more than 5 transactions within a 1-minute tumbling window.

## Generating sample data

To generate sample data, you can use Datagen Source Connectors by executing the [create-datagen-connectors.http](create-datagen-connectors.http) file.