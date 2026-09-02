# Key Concepts

This document covers the core building blocks of EDA. Understanding these is essential before writing your first rulebook.

---

## 1. Rulebooks

A rulebook is a YAML file containing one or more **rule sets**. Each rule set has three parts:

```yaml
---
- name: "Name of this rule set"       # Descriptive name
  hosts: all                           # Target hosts (from inventory)
  sources:                             # WHERE events come from
    - <source plugin>:
        <source parameters>
  rules:                               # WHAT to look for and do
    - name: "Rule name"
      condition: <expression>          # WHEN to act
      action:                          # WHAT to do
        <action type>:
          <action parameters>
```

### Key Points

- A rulebook can have **multiple rule sets** (each with its own source).
- Each rule set can have **multiple rules** (all listening to the same source).
- Rules are evaluated **independently** -- multiple rules can fire from the same event.

---

## 2. Sources

Sources define **where events come from**. They are implemented as **source plugins** from Ansible collections.

### Common Source Plugins

#### Webhook
```yaml
sources:
  - ansible.eda.webhook:
      host: 0.0.0.0
      port: 5000
```
Listens for HTTP POST requests. The request body becomes the event payload.

#### Alertmanager
```yaml
sources:
  - ansible.eda.alertmanager:
      host: 0.0.0.0
      port: 8000
```
Receives alerts from Prometheus Alertmanager. Parses the Alertmanager JSON format automatically.

#### File Watch
```yaml
sources:
  - ansible.eda.file_watch:
      path: /var/log/application.log
      recursive: false
```
Monitors files/directories for changes (created, modified, deleted, moved).

#### Journald
```yaml
sources:
  - ansible.eda.journald:
      match: "SYSLOG_IDENTIFIER=sshd"
```
Reads from the systemd journal, filtered by match expressions.

---

## 3. Conditions

Conditions use a **subset of Jinja2-like expressions** to match events. The event data is accessible via the `event` object.

### Operators

| Operator | Example | Description |
|----------|---------|-------------|
| `==` | `event.payload.status == "firing"` | Equals |
| `!=` | `event.payload.severity != "info"` | Not equals |
| `>`, `>=`, `<`, `<=` | `event.payload.cpu > 90` | Numeric comparison |
| `is defined` | `event.payload.host is defined` | Key exists |
| `is not defined` | `event.payload.region is not defined` | Key missing |
| `is match` | `event.payload.name is match("web.*")` | Regex match |
| `in` | `event.payload.status in ["firing", "warning"]` | Membership |
| `not in` | `event.payload.env not in ["dev", "test"]` | Not a member |
| `and` / `or` | `event.x == 1 and event.y == 2` | Logical operators |

### Condition Examples

```yaml
# Simple equality
condition: event.payload.action == "restart"

# Multiple conditions
condition: event.payload.severity == "critical" and event.payload.environment == "production"

# Nested data
condition: event.payload.alerts[0].labels.alertname == "HighCPU"

# Regex match
condition: event.payload.hostname is match("web-server-.*")

# Check field exists before comparing
condition: event.payload.status is defined and event.payload.status == "firing"
```

### The Event Object

The structure of `event` depends on the source plugin:

- **Webhook**: `event.payload` contains the JSON body of the POST request
- **Alertmanager**: `event.payload` contains the parsed alert data with `alerts[]`, `status`, `labels`, etc.
- **File watch**: `event` has `src_path`, `dest_path`, `type` (created/modified/deleted/moved)
- **Journald**: `event` has journal entry fields like `MESSAGE`, `SYSLOG_IDENTIFIER`, etc.

> **Tip:** Use `action: debug:` in your rules during development to see the full event structure.

---

## 4. Actions

Actions define **what happens** when a condition matches.

### run_job_template (Most Common)

Triggers a job template on AAP Controller:

```yaml
action:
  run_job_template:
    name: "Remediate Service"
    organization: "Default"
    job_args:
      extra_vars:
        target_host: "{{ event.payload.host }}"
        service_name: "{{ event.payload.service }}"
```

Key parameters:
- `name` -- job template name in AAP Controller
- `organization` -- organization the template belongs to
- `job_args.extra_vars` -- pass event data into the playbook as variables

### run_playbook

Runs a playbook directly (standalone mode, not via AAP Controller):

```yaml
action:
  run_playbook:
    name: playbooks/remediate-service.yml
    extra_vars:
      target_host: "{{ event.payload.host }}"
```

> **Note:** `run_playbook` runs locally within the Decision Environment. In production with AAP, prefer `run_job_template`.

### debug

Prints event data to the rulebook activation log (useful for development):

```yaml
action:
  debug:
    msg: "Received event: {{ event }}"
```

### print_event

Prints the full event payload:

```yaml
action:
  print_event:
```

### set_fact / post_event

For advanced workflows:

```yaml
# Store data for later rules
action:
  set_fact:
    fact:
      last_alert: "{{ event.payload.alertname }}"

# Emit a new event into the rule engine
action:
  post_event:
    event:
      custom_type: "escalation"
      original_alert: "{{ event.payload.alertname }}"
```

### Multiple Actions

A single rule can trigger multiple actions using `actions` (plural):

```yaml
rules:
  - name: Alert and remediate
    condition: event.payload.severity == "critical"
    actions:
      - run_job_template:
          name: "Remediate Service"
          organization: "Default"
      - run_job_template:
          name: "Notify Team"
          organization: "Default"
```

---

## 5. Rulebook Activation

In EDA Controller, a **Rulebook Activation** is a running instance of a rulebook. To create one, you need:

| Requirement | Description |
|-------------|-------------|
| **Project** | Git repository containing your rulebooks |
| **Rulebook** | The YAML file to activate (selected from the project) |
| **Decision Environment** | Container image with required collections/plugins |
| **Credentials** | For connecting to AAP Controller and event sources |
| **Instance** | (Optional) Which EDA node runs this activation |

### Activation Lifecycle

```
Disabled  →  Starting  →  Running  →  (events processed)
                                    →  Failed / Stopped
```

### Restart Policy

You can configure what happens if an activation crashes:
- **Always** -- restart automatically
- **Never** -- stay stopped
- **On Failure** -- restart only on error

---

## 6. Event-Driven Tokens

When EDA Controller triggers a job template on AAP Controller, it uses a **Controller Token**. This token must:

- Belong to a user with permission to launch the target job templates
- Be stored as a credential in EDA Controller (type: "Red Hat Ansible Automation Platform")

---

## Summary: How It All Fits Together

```
Source (where)  ──▶  Condition (when)  ──▶  Action (what)
  webhook             event matches          run_job_template
  alertmanager        your criteria          run_playbook
  file_watch                                 debug
  journald                                   set_fact
  custom                                     post_event
```

---

**Next:** [Quick Start](04-quick-start.md)
