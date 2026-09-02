# Event-Driven Ansible (EDA) - Reference Repository

A comprehensive, self-contained reference repository for **Event-Driven Ansible** on **AAP 2.6 / EDA Controller 1.2.1**.

Built for teams working in **offline / air-gapped environments** -- every template is generic, and all environment-specific values live in a single config file (`vars/env-config.yml`).

---

## Who Is This For?

| Audience | Start Here |
|----------|------------|
| **New to EDA** -- never touched it before | [What is EDA?](docs/01-what-is-eda.md) then follow the numbered docs in order |
| **Know Ansible, new to EDA** | [Key Concepts](docs/03-key-concepts.md) then [Quick Start](docs/04-quick-start.md) |
| **Experienced** -- just need skeletons | Jump straight to [rulebooks/](rulebooks/) and [playbooks/](playbooks/) |
| **Setting up offline** | [Offline Setup Guide](docs/06-offline-setup.md) |

---

## Repository Structure

```
.
├── docs/                          # Learning path (numbered, read in order)
│   ├── 01-what-is-eda.md          # What is Event-Driven Ansible?
│   ├── 02-architecture.md         # Architecture & components
│   ├── 03-key-concepts.md         # Rulebooks, sources, rules, actions
│   ├── 04-quick-start.md          # Get running fast
│   ├── 05-decision-environments.md# Decision Environments explained
│   ├── 06-offline-setup.md        # Air-gapped / offline deployment
│   └── 07-troubleshooting.md      # Common issues & fixes
│
├── rulebooks/                     # Ready-to-use rulebook templates
│   ├── webhook/                   # Webhook event source examples
│   ├── alertmanager/              # Alertmanager/Prometheus integration
│   ├── file-watch/                # File & journald monitoring
│   └── custom-source/             # Custom source plugin example
│
├── playbooks/                     # Response playbooks triggered by EDA
│   ├── remediate-service.yml      # Restart a failed service
│   ├── create-ticket.yml          # Open an incident ticket
│   ├── notify-team.yml            # Send team notification
│   └── gather-diagnostics.yml     # Collect diagnostic data
│
├── decision-environment/          # Custom Decision Environment build
│   ├── execution-environment.yml  # EE/DE definition
│   ├── requirements.yml           # Ansible collections
│   ├── requirements.txt           # Python packages
│   └── build.sh                   # One-command build script
│
├── source-plugins/                # Custom event source plugin skeleton
│   └── custom_source/
│       └── my_source.py           # Annotated template
│
├── inventories/                   # Example inventories
│   ├── inventory.yml
│   └── group_vars/all.yml
│
├── vars/                          # Environment-specific configuration
│   └── env-config.yml             # *** EDIT THIS FOR YOUR ENV ***
│
├── scripts/                       # Testing & validation helpers
│   ├── test-webhook.sh            # Send test webhook events
│   ├── test-alertmanager.sh       # Send test Alertmanager alerts
│   └── validate-rulebooks.sh      # Syntax-check all rulebooks
│
└── credentials/                   # Credential setup guide (no secrets stored)
    └── README.md
```

---

## Quick Start (5 minutes)

### 1. Clone and configure

```bash
git clone <this-repo-url>
cd eda-reference

# Edit environment-specific values (controller URLs, registry, ports)
vi vars/env-config.yml
```

### 2. Pick a rulebook

```bash
# List available rulebooks
find rulebooks/ -name '*.yml' | sort
```

### 3. Test locally with ansible-rulebook (optional)

```bash
ansible-rulebook --rulebook rulebooks/webhook/webhook-basic.yml \
                 --inventory inventories/inventory.yml \
                 --verbose
```

### 4. Import into EDA Controller

1. Create a **Project** in EDA Controller pointing to this Git repo.
2. Create a **Rulebook Activation** using one of the rulebooks.
3. Assign a **Decision Environment** (see [DE docs](docs/05-decision-environments.md)).
4. Enable the activation and send a test event (see [scripts/](scripts/)).

---

## Adapting to Your Environment

All environment-specific values are centralized in **`vars/env-config.yml`**. When moving this repo to a different environment:

1. Update `vars/env-config.yml` with your controller URLs, registry, and ports.
2. If using a custom Decision Environment, rebuild it with your Quay registry (see `decision-environment/`).
3. Credentials are managed in EDA Controller -- never stored in this repo.

See [Offline Setup Guide](docs/06-offline-setup.md) for air-gapped deployment instructions.

---

## Version Compatibility

| Component | Version |
|-----------|---------|
| Ansible Automation Platform | 2.6 |
| EDA Controller | 1.2.1 |
| ansible-rulebook | 1.x |
| Decision Environment base | `de-supported-rhel9:latest` |
