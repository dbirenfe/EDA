# Offline / Air-Gapped Setup Guide

This guide covers deploying EDA in environments with **no internet access**. Since you're using Quay as your container registry, the process is straightforward.

---

## Overview: What Needs to Be Offline-Ready

| Component | Online Dependency | Offline Solution |
|-----------|------------------|-----------------|
| Decision Environment image | `registry.redhat.io` | Mirror to your Quay |
| Ansible collections | `galaxy.ansible.com` | Private Automation Hub or local tarballs |
| Python packages | `pypi.org` | Local repo or baked into DE |
| This Git repository | GitHub / external Git | Local GitLab/Gitea or bundle |

---

## Step 1: Mirror the Base DE Image to Quay

On a connected machine:

```bash
# Pull the base image from Red Hat
podman pull registry.redhat.io/ansible-automation-platform-25/de-supported-rhel9:latest

# Tag it for your Quay
podman tag \
  registry.redhat.io/ansible-automation-platform-25/de-supported-rhel9:latest \
  quay.your-domain.com/eda/de-supported-rhel9:latest

# Push to your Quay (or save and transfer)
podman push quay.your-domain.com/eda/de-supported-rhel9:latest
```

If no network path exists between the connected machine and Quay:

```bash
# Save to a tar file on the connected machine
podman save -o de-supported-rhel9.tar \
  registry.redhat.io/ansible-automation-platform-25/de-supported-rhel9:latest

# Transfer the tar file to the offline environment (USB, SCP over internal network, etc.)

# Load into the offline machine's local registry
podman load -i de-supported-rhel9.tar

# Tag and push to offline Quay
podman tag <loaded-image-id> quay.your-domain.com/eda/de-supported-rhel9:latest
podman push quay.your-domain.com/eda/de-supported-rhel9:latest
```

---

## Step 2: Mirror Ansible Collections

### Option A: Private Automation Hub (Recommended)

If you have a Private Automation Hub:

1. On a connected Hub (or using `ansible-galaxy` on a connected machine), sync the required collections:
   - `ansible.eda`
   - Any other collections your playbooks/rulebooks need
2. Export from the connected Hub and import into your offline Hub.
3. Configure `ansible.cfg` or the DE build to pull from your private Hub:

```ini
# ansible.cfg
[galaxy]
server_list = private_hub

[galaxy_server.private_hub]
url = https://hub.your-domain.com/api/galaxy/content/published/
token = <your-token>
```

### Option B: Local Tarball Files

On a connected machine:

```bash
# Download collections as tarballs
ansible-galaxy collection download ansible.eda -p ./collections/
```

Transfer the `collections/` directory to the offline environment. During DE build, reference local paths:

```yaml
# requirements.yml
collections:
  - name: ./collections/ansible-eda-1.5.0.tar.gz
    type: file
```

---

## Step 3: Mirror Python Packages

On a connected machine:

```bash
# Download Python packages
pip download -r decision-environment/requirements.txt -d ./python-packages/
```

Transfer to offline environment. During DE build, serve from a local directory by adding to `execution-environment.yml`:

```yaml
additional_build_steps:
  prepend_final:
    - COPY python-packages/ /tmp/python-packages/
    - RUN pip install --no-index --find-links /tmp/python-packages/ -r /tmp/requirements.txt
```

---

## Step 4: Transfer This Git Repository

### Option A: Git Bundle

```bash
# On the connected machine
git bundle create eda-reference.bundle --all

# Transfer the bundle file to offline environment

# On the offline machine
git clone eda-reference.bundle eda-reference
```

### Option B: Local Git Server

Push this repository to your internal GitLab/Gitea/etc. EDA Controller can then create a Project pointing to the internal Git URL.

---

## Step 5: Build the Custom DE Offline

Once all components are mirrored:

```bash
cd decision-environment/

# Edit execution-environment.yml to use your Quay base image
# Edit requirements.yml to use local collection paths (if not using Private Hub)

ansible-builder build \
  --file execution-environment.yml \
  --tag quay.your-domain.com/eda/custom-de:latest \
  --container-runtime podman

podman push quay.your-domain.com/eda/custom-de:latest
```

---

## Step 6: Configure EDA Controller

1. **Decision Environment** -- point to `quay.your-domain.com/eda/custom-de:latest`
2. **Project** -- point to your internal Git server URL
3. **Credentials** -- set up:
   - AAP Controller token
   - Quay registry credential
   - Git credential (if internal Git requires auth)

---

## Checklist: Offline Deployment

```
[ ] Base DE image mirrored to Quay
[ ] Ansible collections available (Private Hub or local tarballs)
[ ] Python packages available (in DE image or local repo)
[ ] This Git repo accessible from internal Git server
[ ] Custom DE built and pushed to Quay
[ ] EDA Controller configured with internal URLs
[ ] AAP Controller token credential created in EDA Controller
[ ] Quay registry credential created in EDA Controller
[ ] Test rulebook activation running successfully
```

---

## Environment-Specific Values to Change

All in `vars/env-config.yml`:

| Variable | What to Change |
|----------|---------------|
| `aap_controller.host` | Your AAP Controller URL |
| `eda_controller.host` | Your EDA Controller URL |
| `registry.host` | Your Quay hostname |
| `registry.namespace` | Your Quay namespace |
| `offline.private_hub_url` | Your Private Hub URL |
| `offline.collections_path` | Local path if using tarballs |

---

**Next:** [Troubleshooting](07-troubleshooting.md)
