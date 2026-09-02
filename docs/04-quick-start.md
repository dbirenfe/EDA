# Quick Start

This guide gets you up and running with EDA in 10 minutes. It assumes you have:

- Access to an EDA Controller instance
- Access to an AAP Controller instance
- A basic understanding of Ansible playbooks and job templates

---

## Step 1: Configure Your Environment

Edit `vars/env-config.yml` with your actual endpoints:

```yaml
aap_controller:
  host: "https://controller.your-domain.com"
  username: "eda-service-account"

eda_controller:
  host: "https://eda.your-domain.com"

registry:
  host: "quay.your-domain.com"
```

---

## Step 2: Create a Job Template in AAP Controller

EDA triggers **job templates**, so you need at least one to test with.

1. In AAP Controller, go to **Resources → Templates → Add → Job Template**.
2. Create a simple template:
   - **Name:** `EDA Test - Debug`
   - **Project:** Any project with a playbook
   - **Playbook:** Use `playbooks/gather-diagnostics.yml` from this repo (or any simple playbook)
   - **Inventory:** Select an appropriate inventory
3. Under **Extra Variables**, enable **"Prompt on launch"** so EDA can pass event data.

---

## Step 3: Set Up EDA Controller

### 3a. Create a Credential for AAP Controller

1. In EDA Controller, go to **Credentials → Add**.
2. Choose credential type: **Red Hat Ansible Automation Platform**.
3. Fill in:
   - **Name:** `AAP Controller Token`
   - **Controller URL:** `https://controller.your-domain.com`
   - **Token:** A personal access token from AAP Controller (create one under your user settings)

### 3b. Create a Project

1. Go to **Projects → Add**.
2. Fill in:
   - **Name:** `EDA Reference`
   - **SCM Type:** Git
   - **SCM URL:** URL of this repository
   - **Credential:** (Git credential if repo is private)
3. Click **Save** and wait for sync to complete.

### 3c. Create a Decision Environment

If you haven't built a custom DE yet, use the default:

1. Go to **Decision Environments → Add**.
2. Fill in:
   - **Name:** `Default DE`
   - **Image:** `registry.redhat.io/ansible-automation-platform-25/de-supported-rhel9:latest`
   - **Credential:** (Registry credential for `registry.redhat.io` or your Quay mirror)

### 3d. Create a Rulebook Activation

1. Go to **Rulebook Activations → Add**.
2. Fill in:
   - **Name:** `Webhook Test`
   - **Project:** `EDA Reference`
   - **Rulebook:** `rulebooks/webhook/webhook-basic.yml`
   - **Decision Environment:** `Default DE`
   - **Credential:** `AAP Controller Token`
   - **Restart Policy:** `On Failure`
3. Click **Save**, then **Enable** the activation.

---

## Step 4: Send a Test Event

Once the activation is running, send a test webhook:

```bash
# From any host that can reach the EDA Controller
# Adjust the URL and port to match your activation's listener
curl -X POST http://eda.your-domain.com:5000/endpoint \
  -H "Content-Type: application/json" \
  -d '{
    "action": "restart",
    "host": "webserver01",
    "service": "httpd",
    "severity": "warning"
  }'
```

Or use the helper script:

```bash
./scripts/test-webhook.sh http://eda.your-domain.com:5000
```

---

## Step 5: Verify It Worked

1. **EDA Controller** -- Go to **Rule Audit** to see matched events and fired actions.
2. **AAP Controller** -- Check **Jobs** to see if the job template was triggered.
3. **Activation logs** -- Click on your activation → **History** → view logs for event details.

---

## What to Try Next

| Goal | Resource |
|------|----------|
| Understand the full event structure | Add `action: debug:` to a rule and check activation logs |
| Try Alertmanager events | See `rulebooks/alertmanager/` and `scripts/test-alertmanager.sh` |
| Monitor files for changes | See `rulebooks/file-watch/` |
| Build a custom Decision Environment | See [Decision Environments](05-decision-environments.md) |
| Write a custom source plugin | See `source-plugins/` |

---

**Next:** [Decision Environments](05-decision-environments.md)
