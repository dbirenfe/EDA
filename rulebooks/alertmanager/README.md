# Alertmanager Rulebooks

The `ansible.eda.alertmanager` source plugin listens for HTTP POST requests from Prometheus Alertmanager. It automatically parses the Alertmanager webhook format.

## Alertmanager Configuration

Point your Alertmanager to send webhooks to EDA:

```yaml
# alertmanager.yml
receivers:
  - name: eda
    webhook_configs:
      - url: http://<eda-host>:8000/endpoint
        send_resolved: true
```

## Event Structure

Alertmanager sends events in this format. In your conditions, access via `event.payload`:

```json
{
  "payload": {
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
          "summary": "CPU usage above 90%",
          "description": "CPU on webserver01 has been above 90% for 5 minutes"
        },
        "startsAt": "2024-01-15T10:00:00.000Z",
        "endsAt": "0001-01-01T00:00:00Z"
      }
    ],
    "groupLabels": { "alertname": "HighCPU" },
    "commonLabels": { "severity": "critical" }
  }
}
```

## Common Condition Patterns

```yaml
# Match by alert name
condition: event.payload.alerts[0].labels.alertname == "HighCPU"

# Match by severity
condition: event.payload.alerts[0].labels.severity == "critical"

# Match firing alerts only (not resolved)
condition: event.payload.status == "firing"

# Combined
condition: >
  event.payload.status == "firing" and
  event.payload.alerts[0].labels.severity == "critical"
```

## Files

| File | Description |
|------|-------------|
| `alertmanager-basic.yml` | Catches all Alertmanager events, prints them |
| `alertmanager-filtered.yml` | Routes alerts by name and severity to different job templates |

## Testing

```bash
./scripts/test-alertmanager.sh http://<eda-host>:8000
```
