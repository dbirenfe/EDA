#!/usr/bin/env bash
# ===========================================================================
# Test Alertmanager Source
# ===========================================================================
# Sends sample Alertmanager-formatted events to an EDA alertmanager listener.
# The payload matches the real Alertmanager webhook format.
#
# Usage:
#   ./scripts/test-alertmanager.sh                         # default: http://localhost:8000
#   ./scripts/test-alertmanager.sh http://eda.example.com:8000
# ===========================================================================

set -euo pipefail

BASE_URL="${1:-http://localhost:8000}"
ENDPOINT="${BASE_URL}/endpoint"

echo "============================================"
echo " Sending test Alertmanager events to: ${ENDPOINT}"
echo "============================================"
echo ""

# --- Test 1: Critical firing alert (HighCPU) ---
echo ">>> Test 1: Critical firing alert - HighCPU"
curl -s -w "\n    HTTP Status: %{http_code}\n" -X POST "${ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "4",
    "status": "firing",
    "alerts": [
      {
        "status": "firing",
        "labels": {
          "alertname": "HighCPU",
          "severity": "critical",
          "instance": "webserver01:9090",
          "job": "node-exporter"
        },
        "annotations": {
          "summary": "CPU usage above 90% on webserver01",
          "description": "CPU on webserver01 has been above 90% for 5 minutes"
        },
        "startsAt": "2024-01-15T10:00:00.000Z",
        "endsAt": "0001-01-01T00:00:00Z",
        "generatorURL": "http://prometheus:9090/graph"
      }
    ],
    "groupLabels": { "alertname": "HighCPU" },
    "commonLabels": { "alertname": "HighCPU", "severity": "critical" },
    "commonAnnotations": { "summary": "CPU usage above 90%" },
    "externalURL": "http://alertmanager:9093"
  }'
echo ""

sleep 1

# --- Test 2: Warning firing alert (DiskSpace) ---
echo ">>> Test 2: Warning firing alert - DiskSpace"
curl -s -w "\n    HTTP Status: %{http_code}\n" -X POST "${ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "4",
    "status": "firing",
    "alerts": [
      {
        "status": "firing",
        "labels": {
          "alertname": "DiskSpaceWarning",
          "severity": "warning",
          "instance": "db01:9090",
          "job": "node-exporter",
          "mountpoint": "/var"
        },
        "annotations": {
          "summary": "Disk space above 80% on db01:/var",
          "description": "/var partition on db01 is 85% full"
        },
        "startsAt": "2024-01-15T10:05:00.000Z",
        "endsAt": "0001-01-01T00:00:00Z",
        "generatorURL": "http://prometheus:9090/graph"
      }
    ],
    "groupLabels": { "alertname": "DiskSpaceWarning" },
    "commonLabels": { "alertname": "DiskSpaceWarning", "severity": "warning" },
    "commonAnnotations": {},
    "externalURL": "http://alertmanager:9093"
  }'
echo ""

sleep 1

# --- Test 3: Resolved alert ---
echo ">>> Test 3: Resolved alert - HighCPU"
curl -s -w "\n    HTTP Status: %{http_code}\n" -X POST "${ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "4",
    "status": "resolved",
    "alerts": [
      {
        "status": "resolved",
        "labels": {
          "alertname": "HighCPU",
          "severity": "critical",
          "instance": "webserver01:9090",
          "job": "node-exporter"
        },
        "annotations": {
          "summary": "CPU usage back to normal on webserver01"
        },
        "startsAt": "2024-01-15T10:00:00.000Z",
        "endsAt": "2024-01-15T10:15:00.000Z",
        "generatorURL": "http://prometheus:9090/graph"
      }
    ],
    "groupLabels": { "alertname": "HighCPU" },
    "commonLabels": { "alertname": "HighCPU", "severity": "critical" },
    "commonAnnotations": {},
    "externalURL": "http://alertmanager:9093"
  }'
echo ""

echo "============================================"
echo " All test events sent."
echo " Check EDA Controller → Rule Audit for results."
echo "============================================"
