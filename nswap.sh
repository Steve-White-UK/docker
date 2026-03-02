#!/bin/bash
#
# swap.sh - Test helper script for the Solana API
#
# Description:
#   Makes a POST request to the local /swap-instructions endpoint with mock
#   0x headers and the specified token swap parameters. Useful for local
#   development and testing of the swap functionality.
#
# Usage:
#   ./swap.sh <amount_in> <token_in> <token_out>
#
# Arguments:
#   amount_in  - The amount of input token (in base units)
#   token_in   - The mint address of the input token
#   token_out  - The mint address of the output token
#
# Example:
#   ./swap.sh 10000000 \
#             So11111111111111111111111111111111111111112 \
#             EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v
#
# Notes:
#   - Targets localhost:3002
#   - Uses a hardcoded taker address

set -e

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <amount_in> <token_in> <token_out>"
  exit 1
fi

AMOUNT_IN="$1"
TOKEN_IN="$2"
TOKEN_OUT="$3"

ZEROEX_ZID=0x$(openssl rand -hex 12)
ZEROEX_APP_ID="clt8h27ab0000vfh9d6xj2l0q"
ZEROEX_TEAM_ID="clt8h27ab1111vfh9d6xj2l0r"
STORE="graph_service"

TAKER="4iqPxXZf9NpfockoM17oBx3zSJ6rY9ToHRNeysbyDRnU"

curl -X POST \
  -H "Content-Type: application/json" \
  -H "0x-app-id: ${ZEROEX_APP_ID}" \
  -H "0x-team-id: ${ZEROEX_TEAM_ID}" \
  -H "0x-zid: ${ZEROEX_ZID}" \
  -H "0x-tier: 1" \
  -d "{
        \"token_out\": \"${TOKEN_OUT}\",
        \"token_in\": \"${TOKEN_IN}\",
        \"amount_in\": ${AMOUNT_IN},
        \"taker\": \"${TAKER}\",
        \"pool_store_kind\": \"${STORE}\"
      }" \
  http://localhost:3010/swap-instructions
  curl -X POST \
    -H "Content-Type: application/json" \
    -H "0x-app-id: ${ZEROEX_APP_ID}" \
    -H "0x-team-id: ${ZEROEX_TEAM_ID}" \
    -H "0x-zid: ${ZEROEX_ZID}" \
    -H "0x-tier: 1" \
    -d "{
          \"token_out\": \"${TOKEN_OUT}\",
          \"token_in\": \"${TOKEN_IN}\",
          \"amount_in\": ${AMOUNT_IN},
          \"taker\": \"${TAKER}\"
        }" \
    http://localhost:3010/swap-instructions
