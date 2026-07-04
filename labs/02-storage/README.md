# Lab 02 — Secured Storage Platform

**Scenario:** A company stores application logs and a departmental file share. Requirements: network-restricted access, automatic archiving of old logs, read access during a regional outage, and time-limited external sharing.

**AZ-104 skills:** storage accounts · replication (LRS/ZRS/GRS/RA-GRS) · firewall + service endpoints · lifecycle management (JSON) · Azure Files · SAS · AzCopy

**Estimated cost:** < €1 if cleaned up same week · **Time:** 2–3 h

## Architecture

```
rg-lab02-storage (westeurope)
├── vnet-lab02 / snet-app  ── service endpoint: Microsoft.Storage
├── stlab02logs<unique>    (StorageV2, RA-GRS)
│   ├── container: logs    (firewall: snet-app only)
│   └── lifecycle rule: Cool @30d → Delete @365d
└── stlab02files<unique>   (Azure Files share: dept-share)
```

## Tasks

### 1. Create the accounts (CLI) and justify the replication choice
```bash
az group create -n rg-lab02-storage -l westeurope --tags CostCenter=LAB
az storage account create -n stlab02logs$RANDOM -g rg-lab02-storage \
  -l westeurope --sku Standard_RAGRS --kind StorageV2 \
  --min-tls-version TLS1_2 --allow-blob-public-access false
```
Document in a short table: LRS vs ZRS vs GRS vs RA-GRS — and **why RA-GRS** meets "read during regional outage without failover".

### 2. Network restriction — the two-sided door
```bash
az network vnet create -g rg-lab02-storage -n vnet-lab02 \
  --address-prefix 10.2.0.0/16 --subnet-name snet-app --subnet-prefix 10.2.1.0/24
az network vnet subnet update -g rg-lab02-storage --vnet-name vnet-lab02 \
  -n snet-app --service-endpoints Microsoft.Storage
az storage account network-rule add -g rg-lab02-storage \
  --account-name <ACCOUNT> --vnet-name vnet-lab02 --subnet snet-app
az storage account update -g rg-lab02-storage -n <ACCOUNT> --default-action Deny
```
**Validation:** access from your own IP now fails (403 / AuthorizationFailure); access from a VM inside `snet-app` (deploy a temporary B-series VM, or reuse Lab 03) succeeds. Screenshot both. Document that the **service endpoint on the subnet + network rule on the account** must exist together.

### 3. Lifecycle management written as JSON
Create `lifecycle.json` (tierToCool @30d, delete @365d, prefix `logs/`) and apply:
```bash
az storage account management-policy create \
  --account-name <ACCOUNT> -g rg-lab02-storage --policy @lifecycle.json
```
Explain the timeline of a blob in the README (0 → 30 → 365 days).

### 4. Azure Files
Create a share `dept-share`, mount it (SMB) from a VM or from your local machine, upload files, show quota. Document the port requirement (445) and what to do when an ISP blocks it (VPN / private endpoint as alternatives).

### 5. SAS — time-limited external access
Generate a **read-only, 24 h, container-scoped** SAS via CLI; test it in a private browser window; show it failing after revoking (rotate key or use stored access policy). Document why SAS beats sharing account keys.

### 6. AzCopy
Copy a local folder of sample logs into the container with `azcopy copy`; capture the transfer summary output.

## Evidence checklist
- [ ] Replication comparison table + chosen SKU visible in portal
- [ ] 403 from public internet vs success from the subnet
- [ ] Lifecycle policy JSON + portal view of the rule
- [ ] Mounted file share screenshot
- [ ] SAS working, then failing after revocation

## What broke and how I fixed it
*(e.g. propagation delay after --default-action Deny, port 445 blocked, etc.)*

## Cleanup
```bash
az group delete -n rg-lab02-storage --yes --no-wait
```
