# Troubleshooting

Common issues and how to fix them.

---

## Rulebook Activation Issues

### Activation stays in "Starting" and never reaches "Running"

**Likely causes:**
1. Decision Environment image can't be pulled (check registry credentials and network)
2. Collection dependencies are missing from the DE

**Debug steps:**
```bash
# Check if the DE image is accessible
podman pull quay.your-domain.com/eda/custom-de:latest

# Check activation logs in EDA Controller UI:
# Rulebook Activations → <your activation> → History → View logs
```

### Activation fails immediately with "ModuleNotFoundError"

A Python package is missing from the Decision Environment.

**Fix:** Add the package to `decision-environment/requirements.txt`, rebuild and push the DE.

### Activation fails with "Collection not found"

An Ansible collection is missing from the Decision Environment.

**Fix:** Add the collection to `decision-environment/requirements.yml`, rebuild and push the DE.

---

## Event Processing Issues

### Events are sent but no rules fire

**Debug checklist:**

1. **Is the activation running?** Check status in EDA Controller.
2. **Is the event reaching EDA?** Add a catch-all debug rule:
   ```yaml
   rules:
     - name: Debug - catch everything
       condition: true
       action:
         debug:
           msg: "Caught event: {{ event }}"
   ```
3. **Is the condition correct?** The event structure might differ from what you expect. Use `debug` to inspect the full event payload.
4. **Are you hitting the right port?** The webhook/alertmanager listener port must match what's in the rulebook.

### Webhook returns connection refused

- The activation must be running before sending events.
- The port in the rulebook source must be accessible from the event sender.
- Check if a firewall is blocking the port.
- In EDA Controller, the port is exposed through the activation's configuration.

### Alertmanager events not matching

Alertmanager sends events in a specific JSON structure. The event payload looks like:

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
          "instance": "webserver01:9090"
        },
        "annotations": {
          "summary": "CPU usage above 90%"
        }
      }
    ]
  }
}
```

Match against `event.payload.alerts[0].labels.alertname`, not `event.alertname`.

---

## AAP Controller Integration Issues

### "run_job_template" fails with 403 Forbidden

The EDA Controller token doesn't have permission to launch the job template.

**Fix:**
1. In AAP Controller, verify the user whose token you're using has **Execute** permission on the job template.
2. Regenerate the token if it has expired.

### Job template triggered but extra_vars are empty

- Ensure the job template has **"Prompt on launch"** enabled for Extra Variables.
- Verify the Jinja2 expressions in your rulebook action are correct:
  ```yaml
  job_args:
    extra_vars:
      my_var: "{{ event.payload.some_field }}"
  ```

### EDA Controller can't reach AAP Controller

- Verify the URL in the credential is correct (including `https://`).
- Check `validate_certs` -- set to `false` if using self-signed certificates.
- Test connectivity from the EDA Controller host:
  ```bash
  curl -k https://controller.your-domain.com/api/v2/ping/
  ```

---

## Decision Environment Build Issues

### ansible-builder fails with "no such image"

The base image in `execution-environment.yml` isn't available.

**Fix for offline:** Mirror the base image to your Quay first (see [Offline Setup](06-offline-setup.md)).

### ansible-builder fails downloading collections

In an offline environment, `ansible-galaxy` can't reach `galaxy.ansible.com`.

**Fix:** Use local tarball paths in `requirements.yml` or configure `ansible.cfg` to use Private Automation Hub.

### Built image is very large

- Avoid adding unnecessary collections or packages.
- Use multi-stage builds if possible.
- The base `de-supported-rhel9` image is already ~800MB; a custom DE is typically 1-1.5GB.

---

## Validation Commands

```bash
# Validate rulebook syntax (requires ansible-rulebook installed)
ansible-rulebook --rulebook <path> --check

# List available source plugins in your environment
pip show ansible-rulebook

# Check collection versions
ansible-galaxy collection list

# Test AAP Controller connectivity
curl -sk -H "Authorization: Bearer <token>" \
  https://controller.your-domain.com/api/v2/ping/ | python3 -m json.tool

# Test EDA Controller connectivity
curl -sk https://eda.your-domain.com/api/eda/v1/
```

---

## Logs to Check

| Component | Log Location |
|-----------|-------------|
| EDA Controller | Web UI → Rulebook Activations → History |
| EDA Controller service | `journalctl -u automation-eda-*` |
| AAP Controller job output | Web UI → Jobs → <job-id> |
| ansible-rulebook (CLI) | stdout/stderr when run directly |

---

## Getting Help

1. **Event structure unclear?** Use `action: debug:` to print the full event.
2. **Condition not matching?** Start with `condition: true` (matches everything) and narrow down.
3. **Connectivity issue?** Test with `curl` from the EDA Controller host first.
4. **DE build fails?** Build step-by-step: base image first, then add collections, then Python packages.
