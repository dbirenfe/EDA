# Playbooks

Example response playbooks that EDA can trigger via job templates. These demonstrate common remediation patterns.

## How EDA Uses Playbooks

EDA does **not** run these playbooks directly in production. Instead:

1. These playbooks are part of a **Project** in AAP Controller.
2. You create a **Job Template** that references the playbook.
3. EDA triggers the **Job Template** via `run_job_template` action.
4. AAP Controller runs the playbook on the target hosts.

The `extra_vars` from the EDA event are passed through to the playbook.

## Files

| File | Description | Typical Trigger |
|------|-------------|-----------------|
| `remediate-service.yml` | Restart a failed service | Alertmanager critical alert |
| `create-ticket.yml` | Create an incident ticket (stub) | Any alert that needs tracking |
| `notify-team.yml` | Send a notification | Critical events, resolved alerts |
| `gather-diagnostics.yml` | Collect system diagnostic data | Warning alerts, pre-investigation |

## Extra Variables from EDA

These playbooks expect `extra_vars` passed from the EDA rulebook action. Common variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `target_host` | Host to act on | `webserver01` |
| `service_name` | Service to remediate | `httpd` |
| `alert_name` | Name of the alert | `HighCPU` |
| `severity` | Alert severity | `critical` |
| `alert_summary` | Human-readable summary | `CPU usage above 90%` |
| `message` | Free-form message | `Alert resolved` |
