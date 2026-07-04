# Lab 05 — Backup, Recovery & Monitoring

**Scenario:** A production VM must be protected with geo-redundant backup and be restorable in another region. Operations must be alerted by e-mail on high CPU, and unhealthy hosts must be detectable via log queries.

**AZ-104 skills:** Recovery Services vault (region + redundancy sequence) · GRS + Cross-Region Restore · backup policy · restore drill · soft delete · Backup vault vs Recovery Services vault · action groups · metric alerts · Log Analytics + KQL

**Estimated cost:** €1–3 for a few days of one protected instance · **Time:** 3 h + backup wait times (start the first backup, do other work, return)

## Architecture

```
rg-lab05-bcdr (westeurope)
├── vm-prod1 (B1s — the protected workload)
├── rsv-lab05 (Recovery Services vault, westeurope, GRS + CRR)
│   ├── Policy: daily backup, 7-day retention
│   └── Protected item: vm-prod1
├── ag-ops (action group → e-mail)
├── Alert rule: CPU > 80% (5 min) → ag-ops
└── log-lab05 (Log Analytics workspace + VM insights)
```

## Tasks

### 1. The sequence that must be right the first time
Create the vault **in the same region as the VM**, set redundancy **before** protecting anything:
```bash
az backup vault create -g rg-lab05-bcdr -n rsv-lab05 -l westeurope
az backup vault backup-properties set -g rg-lab05-bcdr -n rsv-lab05 \
  --backup-storage-redundancy GeoRedundant --cross-region-restore-flag true
```
Document explicitly: (a) vault and VM must share a region; (b) redundancy is locked after the first protected item; (c) CRR requires GRS. *(Optional demonstration: create a second vault in another region and screenshot the VM not appearing in its protection list.)*

### 2. Protect the VM
Enable backup with a daily policy, 7-day retention; trigger `backup now`; capture the job progressing and completing.

### 3. Restore drill — the part most people skip
Perform a **file-level recovery** (mount the recovery point, retrieve one file) and/or restore the VM as a new VM (`vm-prod1-restored`), prove it boots, then delete it. A documented, successful restore is the strongest business-continuity evidence a portfolio can show.

### 4. Soft delete
Stop protection deleting backup data → show the item in **soft-deleted** state → **undelete** it. Document the 14-day retention window.

### 5. Vault taxonomy
Short comparison in the README: Recovery Services vault (VMs, SQL/SAP in VM, Azure Files, MARS) vs Backup vault (blobs, managed disks, PostgreSQL) — and where this lab's workload belongs.

### 6. Action group + metric alert (the enabling order)
```bash
az monitor action-group create -g rg-lab05-bcdr -n ag-ops \
  --short-name ops --action email admin <YOUR_EMAIL>
az monitor metrics alert create -g rg-lab05-bcdr -n alert-cpu-high \
  --scopes $(az vm show -g rg-lab05-bcdr -n vm-prod1 --query id -o tsv) \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m --evaluation-frequency 1m --action ag-ops
```
Generate CPU load (`stress-ng` via run-command); screenshot the fired alert and the received e-mail. Document why the action group is the enabling step (an alert without one fires silently).

### 7. Log Analytics + KQL
Create a workspace, enable VM insights on vm-prod1, run and document:
```kusto
Heartbeat
| where TimeGenerated > ago(30m)
| summarize last_seen = max(TimeGenerated) by Computer
| where last_seen < ago(10m)
```
Stop the VM, wait, re-run — show the VM appearing in the "silent hosts" result. Explain the query line by line in the README.

## Evidence checklist
- [ ] Vault with GRS + CRR set before first backup
- [ ] Completed backup job
- [ ] Successful restore (file-level and/or full VM)
- [ ] Soft-deleted item recovered
- [ ] Alert fired + e-mail received
- [ ] KQL query catching the stopped VM

## What broke and how I fixed it
*(e.g. first backup taking long, alert evaluation delay, agent provisioning, etc.)*

## Cleanup (vault deletion has its own sequence — document it)
```bash
# 1. Disable soft delete on the vault, 2. stop protection + delete data,
# 3. only then the vault can be removed:
az backup vault delete -g rg-lab05-bcdr -n rsv-lab05 --yes
az group delete -n rg-lab05-bcdr --yes --no-wait
```
