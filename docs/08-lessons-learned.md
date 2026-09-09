# Lessons Learned from Testing

Practical issues discovered while testing this repo on AAP 2.6 / EDA Controller 1.2.1 on OCP 4.20.

---

## 1. Condition Syntax: `and` vs `all:`

**Problem:** Rules with `all:` and a list of conditions never matched.

**Root cause:** In ansible-rulebook, `all:` with a list means "wait for **multiple separate events**", each matching one condition. It does NOT mean "all conditions on the same event".

**Fix:** Use `and` to combine conditions on a single event:

```yaml
# WRONG -- waits for 3 separate events
condition:
  all:
    - event.payload.action == "restart"
    - event.payload.host is defined
    - event.payload.service is defined

# CORRECT -- all conditions on one event
condition: event.payload.action == "restart" and event.payload.host is defined and event.payload.service is defined
```

---

## 2. Playbook Variable Self-Reference

**Problem:** Playbooks crashed with `recursive loop detected in template string`.

**Root cause:** When EDA passes `extra_vars` like `alert_message`, and the playbook has:

```yaml
vars:
  alert_message: "{{ alert_message | default('fallback') }}"
```

Ansible tries to template `alert_message` which references itself → infinite loop.

**Fix:** Use a different local variable name:

```yaml
vars:
  _alert_message: "{{ alert_message | default('fallback') }}"

tasks:
  - debug:
      msg: "{{ _alert_message }}"
```

---

## 3. File Watch Event Structure

**Problem:** `file_watch` rules never matched despite events being generated.

**Root cause:** The `ansible.eda.file_watch` source plugin uses `event.change` for the event type (created/modified/deleted), NOT `event.type`. The `event.type` field contains the watchdog Python class name.

**Fix:**

```yaml
# WRONG
condition: event.type == "created"

# CORRECT
condition: event.change == "created"
```

Full event structure from `ansible.eda.file_watch`:

```json
{
  "change": "created",
  "src_path": "/tmp/eda-test.conf",
  "type": "FileCreatedEvent",
  "root_path": "/tmp"
}
```

> **Note:** `ansible.eda.file_watch` is deprecated as of v2.x. Future versions should use `community.eda.file_watch`.

---

## 4. AAP 2.6 Gateway Architecture

**Key differences from AAP 2.4/2.5:**

- The **platform gateway** provides the unified UI. Deploy via `AnsibleAutomationPlatform` CR, not separate `AutomationController` + `EDA` CRs.
- The Controller API is at `/api/controller/v2/` through the gateway, but EDA's `run_job_template` uses `/api/v2/` directly.
- **EDA credentials** should point to the **controller route** directly (not the gateway), using a **controller-specific token** (not a gateway token).

**Credential setup for EDA → Controller:**

| Field | Value |
|-------|-------|
| Controller URL | `https://<controller-route>` (direct, not gateway) |
| Token | Created via gateway UI → Controller API → Tokens (scope: write) |
| Verify SSL | Unchecked for self-signed certs |

---

## 5. File Watch Path Must Exist

**Problem:** `file_watch` activation crashes immediately.

**Root cause:** The watched directory must exist inside the Decision Environment container when `ansible-rulebook` starts. Custom paths like `/tmp/eda-watch` don't exist in the default DE.

**Fix:** Watch `/tmp` (always exists) and filter by filename prefix in conditions:

```yaml
sources:
  - ansible.eda.file_watch:
      path: /tmp
      recursive: false

rules:
  - name: React to new files
    condition: event.change == "created" and event.src_path is match("/tmp/eda-.*")
```

---

## 6. OCP Storage Considerations

If your cluster uses Ceph/OCS for storage, verify the CSI provisioner is healthy before deploying AAP. On single-node clusters, `hostPath` PVs work well for non-production use:

- Controller postgres needs `ReadWriteOnce`
- Controller projects needs `ReadWriteMany`
- EDA postgres needs `ReadWriteOnce`
- Gateway postgres needs `ReadWriteOnce`

Set correct ownership (namespace UID), permissions (770), and SELinux labels (`container_file_t`) on hostPath directories.

---

## 7. Disk Pressure on OCP

AAP pulls large container images (2-3GB each). On constrained clusters:

- Monitor disk usage before deploying
- Clean up dead/evicted pods regularly
- Watch for runaway deployments creating ghost pods
- The kubelet `imageGCHighThresholdPercent` (default 85%) triggers image garbage collection
