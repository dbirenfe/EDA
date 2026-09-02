# Environment Configuration

This directory holds environment-specific variables used across the repository.

## Files

| File | Purpose |
|------|---------|
| `env-config.yml` | **Main configuration file** -- every environment-specific value lives here |

## How to Use

1. Edit `env-config.yml` with the values matching your target environment (controller URLs, registry, ports, etc.).
2. Rulebooks reference these values via `vars` includes or through EDA Controller extra vars.
3. When moving this repo to a new environment (e.g., from lab to production), **only this file needs to change**.

## Tips

- Never commit passwords or tokens into this file. Use Ansible Vault or EDA Controller credentials instead.
- If you have multiple environments (dev, staging, prod), create copies like `env-config-dev.yml`, `env-config-prod.yml`.
