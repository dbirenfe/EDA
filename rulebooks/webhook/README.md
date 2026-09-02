# Webhook Rulebooks

The `ansible.eda.webhook` source plugin starts an HTTP listener that accepts POST requests. The JSON body of each request becomes the event payload.

## Event Structure

When you POST JSON to the webhook, the event looks like:

```json
{
  "payload": {
    "key1": "value1",
    "key2": "value2"
  }
}
```

Access fields in conditions with: `event.payload.key1`

## Files

| File | Description |
|------|-------------|
| `webhook-basic.yml` | Minimal webhook listener -- catches all events, runs a debug action |
| `webhook-filtered.yml` | Webhook with conditions -- filters by payload fields, triggers job templates |

## Testing

```bash
# Send a test event
curl -X POST http://<eda-host>:5000/endpoint \
  -H "Content-Type: application/json" \
  -d '{"action": "restart", "host": "webserver01", "service": "httpd"}'
```

Or use `scripts/test-webhook.sh`.
