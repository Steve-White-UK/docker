mkdir -p env

# Pool indexer
doppler secrets download \
  --project solana-pool-indexer \
  --config "dev_vixen" \
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
  --config "dev_vixen" \
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