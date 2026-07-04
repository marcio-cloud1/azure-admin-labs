# Lab 01 — Identity & Governance as Code

**Scenario:** A company needs guardrails before any workload is deployed: spending limits, allowed regions, mandatory cost-center tags, delete protection, and least-privilege access for a support team.

**AZ-104 skills:** management groups · Azure Policy (built-in + custom JSON) · RBAC · resource locks · tag governance · budgets

**Estimated cost:** ~ €0 (governance objects are free) · **Time:** 2–3 h

## Architecture

```
Tenant Root Group
└── mg-corp (management group)
    └── Subscription (free trial)
        ├── Budget: lab-budget (alerts 50/80/100%)
        ├── Policy: Allowed locations (Deny) — westeurope, northeurope
        ├── Policy: Inherit CostCenter tag (Modify)
        └── rg-lab01-governance
            ├── Lock: CanNotDelete
            └── Role assignment: Virtual Machine Contributor (scoped here)
```

## Tasks

### 1. Budget first (cost guardrail for the whole portfolio)
Portal → Cost Management → Budgets → create `lab-budget` (e.g. €50/month) with e-mail alerts at 50%, 80%, 100%.
*Evidence: screenshot of budget + alert conditions.*

### 2. Management group
```bash
az account management-group create --name mg-corp --display-name "Corp"
az account management-group subscription add --name mg-corp --subscription <SUB_ID>
```

### 3. Built-in policy — Allowed locations (Deny)
```bash
az policy assignment create \
  --name allowed-locations \
  --scope /providers/Microsoft.Management/managementGroups/mg-corp \
  --policy e56962a6-4747-49cd-b67b-bf8b01975c4c \
  --params '{ "listOfAllowedLocations": { "value": ["westeurope","northeurope"] } }'
```
**Validation:** try to create any resource in `eastus` → expect `RequestDisallowedByPolicy`. Screenshot the error — this is the proof the guardrail works.

### 4. Custom policy — audit public blob access (write the JSON yourself)
Create `policy-audit-public-blob.json`:
```json
{
  "if": {
    "allOf": [
      { "field": "type", "equals": "Microsoft.Storage/storageAccounts" },
      { "field": "Microsoft.Storage/storageAccounts/allowBlobPublicAccess", "notEquals": "false" }
    ]
  },
  "then": { "effect": "audit" }
}
```
```bash
az policy definition create --name audit-public-blob \
  --rules policy-audit-public-blob.json --mode Indexed
az policy assignment create --name audit-public-blob \
  --scope /subscriptions/<SUB_ID> --policy audit-public-blob
```

### 5. Tag inheritance (Modify effect)
Assign built-in policy **"Inherit a tag from the resource group"** with tag name `CostCenter`; create `rg-lab01-governance` with tag `CostCenter=LAB`; deploy any cheap resource inside and show the tag was applied automatically. Run a remediation task and document it.

### 6. RBAC least privilege
```bash
az group create -n rg-lab01-governance -l westeurope --tags CostCenter=LAB
az role assignment create \
  --assignee <TEST_USER_OR_YOUR_UPN> \
  --role "Virtual Machine Contributor" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/rg-lab01-governance
```
Document in the README **why** VM Contributor at RG scope (and not Contributor / not subscription scope).

### 7. Resource lock
```bash
az lock create --name protect-lab01 --lock-type CanNotDelete \
  --resource-group rg-lab01-governance
```
**Validation:** attempt to delete a resource in the RG → expect HTTP 409. Screenshot it. Then document the correct removal workflow (remove lock → delete → re-apply).

## Evidence checklist
- [ ] Budget with alerts
- [ ] Policy denial error in `eastus`
- [ ] Compliance view showing the custom audit policy evaluating resources
- [ ] Inherited tag on a resource + remediation task result
- [ ] 409 error caused by the lock

## What broke and how I fixed it
*(fill in during execution — e.g. policy evaluation delay of up to 30 min, management group permission elevation, etc.)*

## Cleanup
```bash
az lock delete --name protect-lab01 --resource-group rg-lab01-governance
az group delete -n rg-lab01-governance --yes --no-wait
# Keep the budget, the management group and the location policy —
# they protect the remaining labs.
```
