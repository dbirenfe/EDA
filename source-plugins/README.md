# Custom Source Plugins

This directory contains a skeleton for writing your own EDA event source plugin.

## When Do You Need a Custom Source?

The built-in `ansible.eda` collection covers common cases (webhook, alertmanager, file_watch, journald). Write a custom source when you need to:

- Connect to a proprietary monitoring system
- Poll a custom API or database
- Read from a message queue not covered by existing plugins
- Transform or enrich events before they reach the rules engine

## How Source Plugins Work

A source plugin is an **async Python function** that:

1. Receives a queue and configuration arguments.
2. Produces events by putting dictionaries onto the queue.
3. Runs indefinitely (or until stopped).

```python
async def main(queue: asyncio.Queue, args: dict):
    while True:
        event_data = await get_next_event()  # your logic
        await queue.put(event_data)          # send to rules engine
```

## Directory Structure

```
source-plugins/
└── custom_source/
    ├── __init__.py         # Empty, makes it a Python package
    └── my_source.py        # The actual source plugin
```

## Packaging as a Collection

To use your source plugin in EDA Controller, package it as an Ansible collection:

```
myorg/
└── myeda/
    ├── galaxy.yml
    └── plugins/
        └── event_source/
            └── my_source.py    # ← your plugin goes here
    └── extensions/
        └── eda/
            └── rulebooks/
                └── example.yml # optional example rulebook
```

Then build and install the collection:

```bash
cd myorg/myeda/
ansible-galaxy collection build
ansible-galaxy collection install myorg-myeda-1.0.0.tar.gz
```

And include it in your Decision Environment's `requirements.yml`.

## Reference

See `custom_source/my_source.py` for a fully annotated skeleton.

See `rulebooks/custom-source/custom-source-example.yml` for a rulebook that uses a custom source.
