# File Watch & Journald Rulebooks

> **Note:** The `file_watch` and `journald` plugins in `ansible.eda` are deprecated as of v2.x.
> This repo uses `community.eda.file_watch` and `community.eda.journald` instead.
> The `community.eda` collection is included in `decision-environment/requirements.yml`
> -- make sure your custom Decision Environment includes it.

## File Watch

The `ansible.eda.file_watch` (or `community.eda.file_watch`) source plugin monitors files and directories for changes using `inotify`.

### Event Structure

```json
{
  "src_path": "/var/log/application.log",
  "dest_path": "",
  "type": "modified",
  "is_directory": false
}
```

Event types: `created`, `modified`, `deleted`, `moved`

### Common Conditions

```yaml
# Any change to a specific file
condition: event.src_path == "/etc/nginx/nginx.conf"

# Any file created in a directory
condition: event.type == "created"

# Config files modified
condition: event.type == "modified" and event.src_path is match(".*\\.conf$")
```

## Journald

The `ansible.eda.journald` source plugin reads from the systemd journal in real time.

### Event Structure

```json
{
  "MESSAGE": "Failed password for root from 192.168.1.100 port 22 ssh2",
  "SYSLOG_IDENTIFIER": "sshd",
  "PRIORITY": "4",
  "_HOSTNAME": "webserver01"
}
```

### Common Conditions

```yaml
# Match specific service messages
condition: event.SYSLOG_IDENTIFIER == "sshd" and event.MESSAGE is match(".*Failed password.*")

# Match by priority (0=emergency, 7=debug)
condition: event.PRIORITY is defined and event.PRIORITY <= "3"
```

## Files

| File | Description |
|------|-------------|
| `file-watch-basic.yml` | Monitors a directory for any changes |
| `journald-basic.yml` | Watches journald for specific service messages |
