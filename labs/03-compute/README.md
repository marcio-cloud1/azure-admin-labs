# Lab 03 — Compute Deployment Three Ways

**Scenario:** The same web VM must be deployed three ways — Portal, CLI/PowerShell, and Infrastructure as Code — to prove operational fluency. A scale set must absorb load automatically, and the platform must survive a datacenter failure (99.99% SLA).

**AZ-104 skills:** VM deployment (Portal/CLI/PowerShell/Bicep) · availability zones vs sets · VM Scale Sets + autoscale · resize workflow · extensions · ARM/Bicep reading

**Estimated cost:** €2–5 if VMs are deallocated between sessions and deleted at the end · **Time:** 3–4 h

> Cost rules for this lab: use burstable sizes (`Standard_B1s` / `Standard_B2ats_v2`), **deallocate** whenever you pause (`az vm deallocate`), and delete the RG when done. "Stopped" still bills compute; "deallocated" does not — demonstrate this distinction in the README.

## Architecture

```
rg-lab03-compute (westeurope)
├── vm-web-portal   (Zone 1)  ← deployed via Portal
├── vm-web-cli      (Zone 2)  ← deployed via CLI
├── vm-web-bicep    (Zone 3)  ← deployed via Bicep template
└── vmss-web        (zonal, min 2 / max 5, autoscale on CPU)
```

## Tasks

### 1. Portal deployment (baseline, with screenshots of each blade)
Ubuntu LTS, `Standard_B1s`, **Zone 1**, no public IP RDP/SSH exposure — use NSG allowing SSH only from your IP. Install Nginx via *custom data* (cloud-init).

### 2. CLI deployment — Zone 2
```bash
az vm create -g rg-lab03-compute -n vm-web-cli \
  --image Ubuntu2204 --size Standard_B1s --zone 2 \
  --admin-username azureadmin --generate-ssh-keys \
  --custom-data cloud-init.txt
```

### 3. PowerShell inspection — the -Status distinction
```powershell
Get-AzVM -ResourceGroupName rg-lab03-compute -Name vm-web-cli          # model view
Get-AzVM -ResourceGroupName rg-lab03-compute -Name vm-web-cli -Status  # instance view / PowerState
```
Capture both outputs; explain model view vs instance view.

### 4. Bicep deployment — Zone 3
Write `vm.bicep` with parameters (`vmName`, `zone`, `adminUsername`), a NIC resource and an explicit `dependsOn` relationship (or implicit via symbolic reference — document the difference). Deploy:
```bash
az deployment group create -g rg-lab03-compute --template-file vm.bicep \
  --parameters vmName=vm-web-bicep zone=3
```
Commit the template to this folder — reading/writing templates is tested on AZ-104 and valued in interviews.

### 5. Resize workflow
Resize `vm-web-cli` to a size unavailable "hot" and document the correct sequence:
```bash
az vm deallocate -g rg-lab03-compute -n vm-web-cli
az vm resize -g rg-lab03-compute -n vm-web-cli --size Standard_B2ats_v2
az vm start -g rg-lab03-compute -n vm-web-cli
```

### 6. VM Scale Set with autoscale
Create `vmss-web` (min 2, max 5, default 2) across zones 1–3; add rules: +2 instances if CPU > 75% for 10 min; −1 if CPU < 25% for 10 min. Generate load (`stress-ng` via run-command) and screenshot the instance count rising, then falling back to the minimum. Explain in the README why it never goes below 2.

### 7. SLA note
Document: single VM Premium SSD 99.9% · availability set 99.95% · availability zones 99.99% — and which one this lab implements.

## Evidence checklist
- [ ] Three VMs, three zones, three deployment methods
- [ ] `-Status` output showing PowerState
- [ ] Bicep file committed + successful deployment output
- [ ] Deallocate → resize → start sequence
- [ ] Autoscale history graph (scale-out and scale-in events)

## What broke and how I fixed it
*(e.g. size unavailable in region, quota limits on free trial vCPUs, cloud-init not executing, etc.)*

## Cleanup
```bash
az group delete -n rg-lab03-compute --yes --no-wait
```
