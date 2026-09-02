# Decision Environment Build

This directory contains everything needed to build a custom **Decision Environment (DE)** for EDA.

## What is a Decision Environment?

See [docs/05-decision-environments.md](../docs/05-decision-environments.md) for a full explanation.

**TL;DR:** A Decision Environment is a container image that runs your EDA rulebook activations. It contains `ansible-rulebook`, your Ansible collections (including source plugins), and any Python packages your rules need.

## Files

| File | Purpose |
|------|---------|
| `execution-environment.yml` | The DE definition -- input for `ansible-builder` |
| `requirements.yml` | Ansible collections to install in the DE |
| `requirements.txt` | Python packages to install in the DE |
| `build.sh` | One-command build script |

## Quick Build

```bash
# Edit requirements as needed, then:
./build.sh
```

## Manual Build

```bash
# 1. Install ansible-builder on your build host
pip install ansible-builder

# 2. Build the image
ansible-builder build \
  --file execution-environment.yml \
  --tag quay.your-domain.com/eda/custom-de:latest \
  --container-runtime podman \
  --verbosity 3

# 3. Push to Quay
podman push quay.your-domain.com/eda/custom-de:latest
```

## Customization

- Add collections to `requirements.yml`
- Add Python packages to `requirements.txt`
- Edit the base image in `execution-environment.yml` if using a different RHEL/UBI version
- For offline builds, see the inline comments in `execution-environment.yml`
