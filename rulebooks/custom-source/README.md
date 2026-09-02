# Custom Source Plugin Rulebook

Demonstrates how to use a custom event source plugin in a rulebook.

When the built-in sources (webhook, alertmanager, file_watch, journald) don't cover your use case, you can write a custom source plugin and use it in a rulebook.

## How Custom Sources Work

1. You write a Python async generator that yields events (see `source-plugins/`).
2. You package it in an Ansible collection.
3. You include that collection in your Decision Environment.
4. You reference it in your rulebook as `namespace.collection.source_name`.

## Files

| File | Description |
|------|-------------|
| `custom-source-example.yml` | Rulebook using a custom source plugin |

## See Also

- `source-plugins/` -- skeleton for writing your own source plugin
- `decision-environment/` -- how to include your collection in the DE
