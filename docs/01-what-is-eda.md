# What is Event-Driven Ansible (EDA)?

## The Problem EDA Solves

Traditional automation is **reactive by request** -- someone notices an issue, logs in, and runs a playbook. This creates delays:

```
Problem occurs  →  Human notices  →  Human decides  →  Human runs playbook  →  Problem fixed
     ↑                                                                            ↑
     └── This gap can be minutes, hours, or days ─────────────────────────────────┘
```

EDA flips this model. It **watches for events in real time** and **automatically triggers the right response**:

```
Problem occurs  →  Event emitted  →  EDA matches rule  →  Playbook runs  →  Problem fixed
     ↑                                                                          ↑
     └── Seconds ──────────────────────────────────────────────────────────────┘
```

## What is EDA?

Event-Driven Ansible is a capability within the **Ansible Automation Platform (AAP)** that:

1. **Listens** for events from external systems (monitoring tools, webhooks, log files, message queues).
2. **Evaluates** those events against a set of rules you define.
3. **Acts** by triggering Ansible playbooks, job templates, or other actions when rules match.

Think of it as an **"if-this-then-that" engine** for your infrastructure, powered by Ansible.

## Real-World Examples

| Event | Rule | Action |
|-------|------|--------|
| Alertmanager fires `HighCPU` alert | CPU > 90% on a web server | Run a playbook that scales up the service |
| Webhook from Git push | New commit to `main` branch | Trigger a deployment job template |
| Log file shows `disk full` | `/var/log` partition > 95% | Run cleanup playbook, notify team |
| Service health check fails | HTTP 503 for > 2 minutes | Restart the service, open a ticket |

## EDA vs. Traditional Ansible

| Aspect | Traditional Ansible | Event-Driven Ansible |
|--------|-------------------|---------------------|
| **Trigger** | Human runs `ansible-playbook` | Automatic, based on events |
| **Timing** | On-demand / scheduled | Real-time, continuous |
| **Awareness** | None -- runs when told | Listens to event sources |
| **Use case** | Provisioning, configuration | Remediation, response, orchestration |
| **Complement** | -- | Works WITH traditional Ansible, not instead of it |

## Key Takeaway

EDA does **not** replace your existing Ansible playbooks and job templates. It **adds a reactive layer on top** -- your playbooks become the actions that EDA triggers automatically when the right event occurs.

---

**Next:** [Architecture & Components](02-architecture.md)
