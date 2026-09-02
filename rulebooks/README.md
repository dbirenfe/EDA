# Rulebooks

This directory contains ready-to-use rulebook templates organized by event source type.

## Structure

```
rulebooks/
├── webhook/              # HTTP webhook event source
│   ├── webhook-basic.yml
│   └── webhook-filtered.yml
├── alertmanager/         # Prometheus Alertmanager
│   ├── alertmanager-basic.yml
│   └── alertmanager-filtered.yml
├── file-watch/           # File system monitoring
│   ├── file-watch-basic.yml
│   └── journald-basic.yml
└── custom-source/        # Custom source plugin
    └── custom-source-example.yml
```

## How to Use

1. Pick a rulebook that matches your event source.
2. Copy it and adjust parameters (ports, conditions, job template names).
3. Import into EDA Controller via a Project pointing to this Git repo.
4. Create a Rulebook Activation using the rulebook.

## Rulebook Anatomy

Every rulebook follows the same pattern:

```yaml
---
- name: "Rule set name"
  hosts: all
  sources:                        # 1. WHERE do events come from?
    - <source_plugin>:
        <parameters>
  rules:
    - name: "Rule name"
      condition: <expression>     # 2. WHEN should we act?
      action:                     # 3. WHAT should we do?
        <action_type>:
          <parameters>
```

## Customization Checklist

When adapting a rulebook for your environment, check:

- [ ] Source plugin parameters (host, port, path)
- [ ] Condition expressions (match your event payload structure)
- [ ] Job template name and organization
- [ ] Extra variables passed to the job template
