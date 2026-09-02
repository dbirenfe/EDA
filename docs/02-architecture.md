# Architecture & Components

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Event Sources                                │
│                                                                     │
│   ┌───────────┐  ┌──────────────┐  ┌───────────┐  ┌─────────────┐ │
│   │  Webhook   │  │ Alertmanager │  │ File Watch│  │Custom Source│ │
│   └─────┬─────┘  └──────┬───────┘  └─────┬─────┘  └──────┬──────┘ │
│         │                │                │               │         │
└─────────┼────────────────┼────────────────┼───────────────┼─────────┘
          │                │                │               │
          ▼                ▼                ▼               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      EDA Controller                                 │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                    Rulebook Activation                       │   │
│   │                                                             │   │
│   │  ┌──────────┐    ┌──────────────┐    ┌──────────────────┐   │   │
│   │  │  Source   │───▶│  Conditions  │───▶│     Actions      │   │   │
│   │  │ (events)  │    │  (matching)  │    │ (run_job_template│   │   │
│   │  └──────────┘    └──────────────┘    │  run_playbook,   │   │   │
│   │                                      │  debug, etc.)    │   │   │
│   │                                      └────────┬─────────┘   │   │
│   └───────────────────────────────────────────────┼─────────────┘   │
│                                                   │                 │
│   ┌─────────────────────┐   ┌─────────────────┐   │                 │
│   │ Decision Environment│   │   Credentials    │   │                 │
│   │ (container image)   │   │                  │   │                 │
│   └─────────────────────┘   └─────────────────┘   │                 │
└───────────────────────────────────────────────────┼─────────────────┘
                                                    │
                                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      AAP Controller                                 │
│                                                                     │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────────────┐ │
│   │ Job Templates │    │  Inventories  │    │ Execution Environments│ │
│   └──────────────┘    └──────────────┘    └──────────────────────┘ │
│                                                                     │
│   EDA triggers job templates here, which run your playbooks on     │
│   target hosts using the inventories and EEs you've configured.    │
└─────────────────────────────────────────────────────────────────────┘
```

## Components Explained

### 1. Event Sources

External systems that produce events. EDA uses **source plugins** to listen:

| Source Plugin | What It Listens To | Collection |
|---------------|-------------------|------------|
| `ansible.eda.webhook` | HTTP POST requests | `ansible.eda` |
| `ansible.eda.alertmanager` | Prometheus Alertmanager alerts | `ansible.eda` |
| `ansible.eda.file_watch` | File creation/modification/deletion | `ansible.eda` |
| `ansible.eda.journald` | systemd journal logs | `ansible.eda` |
| Custom plugins | Anything you write | Your own collection |

### 2. EDA Controller

The management plane for EDA. It provides:

- **Web UI** for managing rulebooks, activations, and credentials
- **API** for programmatic access
- **Rulebook activation engine** -- runs `ansible-rulebook` inside Decision Environments
- **Credential management** -- securely stores tokens, passwords, certificates
- **Project integration** -- syncs rulebooks from Git repositories

### 3. Rulebook

A YAML file that defines the **source → condition → action** logic. This is the core of EDA. Example structure:

```yaml
---
- name: Respond to webhook events
  hosts: all
  sources:
    - ansible.eda.webhook:
        host: 0.0.0.0
        port: 5000
  rules:
    - name: Match a restart request
      condition: event.payload.action == "restart"
      action:
        run_job_template:
          name: "Restart Service"
          organization: "Default"
```

### 4. Decision Environment (DE)

A **container image** that provides the runtime for `ansible-rulebook`. It contains:

- Python + ansible-rulebook
- Ansible collections (including source plugins)
- Any extra Python packages your rules/sources need

Think of it as an **Execution Environment (EE), but for EDA**.

See [Decision Environments](05-decision-environments.md) for full details.

### 5. AAP Controller

Your existing Automation Controller. EDA Controller communicates with it to:

- **Trigger job templates** (the most common action)
- Use existing **inventories**, **credentials**, and **execution environments**
- Leverage your existing automation content

### 6. Credentials

Stored in EDA Controller, used for:

- Connecting to AAP Controller (controller token)
- Authenticating event sources (e.g., webhook secret)
- Accessing Git repositories (project sync)

## Data Flow (Step by Step)

```
1. Event source emits an event (e.g., Alertmanager sends a firing alert)
                    │
                    ▼
2. Source plugin inside the rulebook activation receives the event
                    │
                    ▼
3. Event is evaluated against all rules in the rulebook
                    │
                    ▼
4. If a condition matches → the action fires
                    │
                    ▼
5. Action (e.g., run_job_template) calls AAP Controller API
                    │
                    ▼
6. AAP Controller launches the job template on target hosts
                    │
                    ▼
7. Playbook runs, problem is remediated
```

---

**Next:** [Key Concepts](03-key-concepts.md)
