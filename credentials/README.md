# Credentials

**No secrets are stored in this repository.**

Credentials are managed in **EDA Controller** and **AAP Controller** through their built-in credential management.

## Credentials You'll Need

### In EDA Controller

| Credential | Type | Purpose |
|------------|------|---------|
| AAP Controller Token | Red Hat Ansible Automation Platform | Allows EDA to trigger job templates |
| Quay Registry | Container Registry | Pull Decision Environment images |
| Git Repository | Source Control | Sync this project from Git |

### In AAP Controller

| Credential | Type | Purpose |
|------------|------|---------|
| Machine Credential | Machine | SSH access to target hosts |
| (Optional) Vault | Vault | Decrypt vaulted variables |

## Creating the AAP Controller Token

1. Log into **AAP Controller** as the EDA service account user.
2. Go to **Users → your user → Tokens → Add**.
3. Set scope to **Write**.
4. Copy the token value.
5. In **EDA Controller**, create a credential:
   - Type: **Red Hat Ansible Automation Platform**
   - URL: `https://controller.your-domain.com`
   - Token: paste the value from step 4

## Security Best Practices

- Use a **dedicated service account** for EDA (not a personal user).
- Grant the service account **minimal permissions** -- only Execute on the job templates EDA needs.
- Rotate tokens periodically.
- Never commit tokens, passwords, or secrets to Git.
