# Decision Environments (DE)

## What is a Decision Environment?

A **Decision Environment** is a container image that provides the runtime for your EDA rulebook activations. It is the EDA equivalent of an **Execution Environment (EE)** in AAP Controller.

### Why Does It Exist?

`ansible-rulebook` needs certain Python packages and Ansible collections to run your rulebooks. Rather than installing these on a bare server, everything is packaged into a container image. This gives you:

- **Consistency** -- same environment everywhere (dev, staging, production)
- **Isolation** -- different activations can use different DEs
- **Portability** -- ship the image to any environment (including offline)

### What's Inside a DE?

```
┌────────────────────────────────────────────────┐
│           Decision Environment Image            │
│                                                │
│  ┌──────────────────────────────────────────┐  │
│  │  Base image (RHEL 9 UBI / de-supported)  │  │
│  ├──────────────────────────────────────────┤  │
│  │  Python 3.11+                            │  │
│  │  ansible-core                            │  │
│  │  ansible-runner                          │  │
│  │  ansible-rulebook                        │  │
│  ├──────────────────────────────────────────┤  │
│  │  Ansible Collections:                    │  │
│  │    - ansible.eda (source plugins)        │  │
│  │    - your custom collections             │  │
│  ├──────────────────────────────────────────┤  │
│  │  Extra Python packages:                  │  │
│  │    - aiohttp, asyncio (for webhooks)     │  │
│  │    - your custom dependencies            │  │
│  └──────────────────────────────────────────┘  │
└────────────────────────────────────────────────┘
```

## Default vs. Custom DE

### Default DE

Red Hat provides a supported base image:

```
registry.redhat.io/ansible-automation-platform-25/de-supported-rhel9:latest
```

This includes `ansible.eda` and common dependencies. Use this if:

- You only need the built-in source plugins (webhook, alertmanager, file_watch, journald)
- You don't need extra Python packages or custom collections

### Custom DE

Build your own when you need:

- Custom source plugins from your own collection
- Additional Python packages
- Specific versions of collections
- Extra system packages

## Building a Custom DE

This repository includes everything you need in the `decision-environment/` directory.

### Files Overview

| File | Purpose |
|------|---------|
| `execution-environment.yml` | DE definition (input for `ansible-builder`) |
| `requirements.yml` | Ansible collections to include |
| `requirements.txt` | Python packages to include |
| `build.sh` | One-command build script |

### Step-by-Step Build

#### 1. Install ansible-builder (on your build host)

```bash
pip install ansible-builder
```

#### 2. Edit the requirements

`requirements.yml` -- add collections:

```yaml
collections:
  - name: ansible.eda
  - name: your_namespace.your_collection
```

`requirements.txt` -- add Python packages:

```
aiohttp
jmespath
```

#### 3. Build the image

```bash
cd decision-environment/
./build.sh
```

Or manually:

```bash
ansible-builder build \
  --file execution-environment.yml \
  --tag quay.your-domain.com/eda/custom-de:latest \
  --container-runtime podman
```

#### 4. Push to your registry (Quay)

```bash
podman push quay.your-domain.com/eda/custom-de:latest
```

#### 5. Register in EDA Controller

1. Go to **Decision Environments → Add**.
2. Set the image to `quay.your-domain.com/eda/custom-de:latest`.
3. Add a registry credential if needed.

## Offline / Air-Gapped Build

When building without internet access:

1. **Mirror collections** -- download `.tar.gz` files on a connected machine and place them in the build context.
2. **Mirror Python packages** -- use `pip download` on a connected machine, then serve from a local directory or repo.
3. **Base image** -- mirror `de-supported-rhel9` to your Quay instance.

See [Offline Setup Guide](06-offline-setup.md) for detailed steps.

## DE vs. EE Comparison

| Aspect | Decision Environment (DE) | Execution Environment (EE) |
|--------|--------------------------|---------------------------|
| **Used by** | EDA Controller / ansible-rulebook | AAP Controller / ansible-runner |
| **Contains** | ansible-rulebook + source plugins | ansible-core + modules/roles |
| **Purpose** | Run rulebook activations | Run playbooks/job templates |
| **Build tool** | `ansible-builder` (same tool) | `ansible-builder` |
| **Base image** | `de-supported-rhel9` | `ee-supported-rhel9` |

> They are built the same way -- the only difference is the base image and what you install.

---

**Next:** [Offline Setup Guide](06-offline-setup.md)
