#!/usr/bin/env bash
# ===========================================================================
# Test Webhook Source
# ===========================================================================
# Sends sample webhook events to an EDA webhook listener.
#
# Usage:
#   ./scripts/test-webhook.sh                         # default: http://localhost:5000
#   ./scripts/test-webhook.sh http://eda.example.com:5000
# ===========================================================================

set -euo pipefail

BASE_URL="${1:-http://localhost:5000}"
ENDPOINT="${BASE_URL}/endpoint"

echo "============================================"
echo " Sending test webhook events to: ${ENDPOINT}"
echo "============================================"
echo ""

# --- Test 1: Service restart request ---
echo ">>> Test 1: Service restart request"
curl -s -w "\n    HTTP Status: %{http_code}\n" -X POST "${ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "restart",
    "host": "webserver01",
    "service": "httpd",
    "severity": "warning"
  }'
echo ""

sleep 1

# --- Test 2: Critical severity event ---
echo ">>> Test 2: Critical severity event"
curl -s -w "\n    HTTP Status: %{http_code}\n" -X POST "${ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "alert",
    "host": "db01",
    "service": "postgresql",
    "severity": "critical",
    "message": "Database connection pool exhausted"
  }'
echo ""

sleep 1

# --- Test 3: Generic event (should hit catch-all) ---
echo ">>> Test 3: Generic event (catch-all)"
curl -s -w "\n    HTTP Status: %{http_code}\n" -X POST "${ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "info",
    "message": "This is a generic test event"
  }'
echo ""

echo "============================================"
echo " All test events sent."
echo " Check EDA Controller → Rule Audit for results."
echo "============================================"
