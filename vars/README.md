# Environment Configuration

This file is **loaded directly** by ansible-rulebook and EDA Controller. No copy-pasting needed.

## How to Use

### CLI (local testing)

```bash
ansible-rulebook --rulebook rulebooks/webhook/webhook-basic.yml \
                 --inventory inventories/inventory.yml \
                 --vars vars/env-config.yml \
                 --verbose
```

### EDA Controller

Paste the contents of `env-config.yml` into the **Extra Variables** field when creating a Rulebook Activation. All activations that use the same environment can share the same block.

## How It Works

Rulebooks reference variables with defaults:

```yaml
# In sources (Jinja2 substitution):
sources:
  - ansible.eda.webhook:
      port: "{{ webhook_port | default(5000) }}"

# In actions (Jinja2 substitution):
action:
  run_job_template:
    name: "{{ remediate_template | default('Remediate Service') }}"
    organization: "{{ aap_organization | default('Default') }}"
```

If you provide `env-config.yml` via `--vars` or Extra Variables, those values override the defaults.
If you don't, the defaults kick in.

## Variables Reference

| Variable | Default | Used By |
|----------|---------|---------|
| `webhook_host` | `0.0.0.0` | Webhook rulebooks (source bind address) |
| `webhook_port` | `5000` | Webhook rulebooks (source listen port) |
| `alertmanager_host` | `0.0.0.0` | Alertmanager rulebooks (source bind address) |
| `alertmanager_port` | `8000` | Alertmanager rulebooks (source listen port) |
| `remediate_template` | `Remediate Service` | Filtered rulebooks (job template name) |
| `notify_template` | `Notify Team` | Filtered rulebooks (job template name) |
| `diagnostics_template` | `Gather Diagnostics` | Alertmanager filtered (job template name) |
| `aap_organization` | `Default` | All `run_job_template` actions |
