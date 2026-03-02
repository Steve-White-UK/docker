# Solana Pool Indexer - Local Development Environment

This directory contains the local development infrastructure for the Solana Pool Indexer project

- Kafka + Kafka UI
- FalkorDB
- OpenTelemetry observability using Dash0

## Setup Instructions

### 1. Create Your Environment File

Copy the example environment file, edit as necessary and source it:

```bash
cp .env.example .env
source .env
```

### 2. Start the Services

Start all services:

```bash
docker-compose up -d
```

### 3. Access Services

- **Kafka UI**: http://localhost:8080
- **FalkorDB**: `redis-cli -h localhost -p 6379`
- **FalkorDB Browser**: http://localhost:3000
- **OTLP endpoints**:
  - gRPC: http://localhost:4317
  - HTTP: http://localhost:4318

## Useful Commands

### View logs for all services or a specific service

```bash
docker-compose logs -f
docker-compose logs -f kafka
```

### Execute commands in Kafka container

```bash
# List topics
docker-compose exec kafka kafka-topics --list --bootstrap-server localhost:9092

# Consume messages from a topic
docker-compose exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic solana-api.indexer.liquidity.raw.v0 --from-beginning

# Delete consumer group topic offsets (e.g. topics were manually removed)
docker-compose exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group redis-writer-v1 --delete
```

### Execute commands in FalkorDB

```bash
# Run a Cypher query
docker-compose exec falkordb redis-cli GRAPH.QUERY solana_pools "MATCH (n) RETURN n LIMIT 10"
```

## Network

All services run on the `solana-network` Docker network, allowing them to communicate using service names as hostnames (e.g., `kafka:29092`, `falkordb:6379`)

## Full Stack Quickstart (Indexer + Pool Store + API + Gateway)

This section describes how to bring up the entire local stack (Kafka, FalkorDB, indexer, writers, pool store service, API, and API gateway) using Docker and Doppler.

### 1. Base `.env` for ports and telemetry

From this directory:

```bash
cp .env.example .env
# Optionally edit .env to change host ports if they clash with existing services
```

### 2. Generate per-service env files from Doppler

Each application service expects a corresponding env file in `./env`. Project names match the Rust binary names with dashes instead of underscores, and the configuration is `dev_test_environment`.

Create the `env` directory and download secrets for each service:

```bash
mkdir -p env

# Pool indexer
doppler secrets download \
  --project solana-pool-indexer \
  --config "dev_dev_test_environment" \
  --no-file \
  --format docker \
  > env/solana-pool-indexer.env

# Indexer → Redis writer
doppler secrets download \
  --project solana-pool-indexer-redis-writer \
  --config "dev_dev_test_environment" \
  --no-file \
  --format docker \
  > env/solana-pool-indexer-redis-writer.env

# Kafka → FalkorDB writer
doppler secrets download \
  --project solana-pool-store-writer \
  --config "dev_test_environment" \
  --no-file \
  --format docker \
  > env/solana-pool-store-writer.env

# Graph gRPC service
doppler secrets download \
  --project solana-pool-store-service \
  --config "dev_dev_test_environment" \
  --no-file \
  --format docker \
  > env/solana-pool-store-service.env

# Public HTTP API
doppler secrets download \
  --project solana-api-router \
  --config "dev_dev_test_environment" \
  --no-file \
  --format docker \
  > env/solana-api.env

# API gateway
doppler secrets download \
  --project solana-api-gateway \
  --config "dev_dev_test_environment" \
  --no-file \
  --format docker \
  > env/solana-api-gateway.env
```

> Tip: add `apps/solana_pool_indexer/local/env/*.env` to your `.gitignore` so these files are never committed.

### 3. Start the full stack

Bring up infra + all application services:

```bash
docker compose up --build
```

This will start:

- Infra: `otel-collector`, `zookeeper`, `kafka`, `kafka-init`, `kafka-ui`, `falkordb`
- Indexer path: `solana-pool-indexer`, `solana-pool-indexer-redis-writer`
- Pool store path: `solana-pool-store-writer`, `solana-pool-store-service`
- API layer: `solana-api`, `solana-api-gateway`

### 4. Useful local endpoints

Assuming you keep the defaults from `.env.example`:

- **Kafka UI**: http://localhost:8080
- **FalkorDB Redis**: `redis-cli -h localhost -p 6379`
- **FalkorDB Browser**: http://localhost:3000
- **Pool Store gRPC**: `localhost:50051`
- **Pool Store health**: http://localhost:3103/healthz
- **Indexer health**: http://localhost:3100/healthz
- **Indexer → Redis writer health**: http://localhost:3101/healthz
- **Pool Store writer health**: http://localhost:3102/healthz
- **Solana API health**: http://localhost:3010/hc
- **Solana API gateway**: http://localhost:3001/swap-instructions
- **API gateway metrics**: http://localhost:8081/metrics

You can stop the stack with `docker compose down` and reset all data (Kafka and FalkorDB volumes) with `docker compose down -v`.

## Data Persistence

The following Docker volumes persist data across restarts:

- `zookeeper-data`: Zookeeper state
- `zookeeper-logs`: Zookeeper transaction logs
- `kafka-data`: Kafka message logs
- `falkordb_data`: FalkorDB graph data

To reset all data, use `docker-compose down -v`
