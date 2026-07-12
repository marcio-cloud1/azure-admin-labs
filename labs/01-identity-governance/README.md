### Prerequisite — Test Identity

Created a test user in Microsoft Entra ID to be used as the target for the
RBAC assignment in Task 6 below.

**Command executed:**
​```powershell
az ad user create --display-name "Test RBAC AZ104" --user-principal-name "teste.rbac@marciomarquesbhgmail.onmicrosoft.com" --password "SenhaForte#2026!"
​```

**Result:** user created successfully (Object ID: `26c446d3-6bf5-40ef-a787-8786848e2090`).

---

**Scenario:** A company needs guardrails before any workload is deployed...
### Task 1 — Budget

Created `lab-budget1` (Cost Management → Budgets), scope: Billing account.
Amount: $50.00 USD/month, resets monthly.
Alerts (actual cost): 50% ($25), 80% ($40), 100% ($50) → email to marciomarquesbh@gmail.com.

**Note:** the original plan targeted Subscription scope; Azure Cost Management
also supports Billing Account, Billing Profile, and Resource Group scopes.
Billing Account scope was used here, which extends the guardrail to any
future subscription under this billing account.
**Scenario:** A company needs guardrails before any workload is deployed: spending limits, allowed regions, mandatory cost-center tags, delete protection, and least-privilege access for a support team.

**AZ-104 skills:** management groups · Azure Policy (built-in + custom JSON) · RBAC · resource locks · tag governance · budgets

**Estimated cost:** ~ $0 (governance objects are free) · **Time:** 2–3 h

## Architecture

```
Tenant Root Group
└── mg-corp (management group)
    └── Subscription (free trial)
        ├── Policy: Allowed locations (Deny) — northeurope, westeurope
        ├── Policy: Inherit CostCenter tag (Modify)
        └── rg-lab01-governance
            ├── Lock: CanNotDelete
            └── Role assignment: Virtual Machine Contributor (scoped here)

Billing Account (Marcio Moreira Marques)
└── Budget: lab-budget1 ($50/month, alerts 50/80/100%)
```

## Tasks

### 1. Budget (✅ completed)
Portal → Cost Management → Budgets → created `lab-budget1`, scope: **Billing Account** (Marcio Moreira Marques). Amount: $50.00 USD/month, resets monthly. Alerts (actual cost): 50% ($25), 80% ($40), 100% ($50) → email to marciomarquesbh@gmail.com.

**Note:** the original plan targeted Subscription scope; Azure Cost Management also supports Billing Account, Billing Profile, and Resource Group scopes. Billing Account scope was used here, which extends the guardrail to any future subscription under this billing account.

*Evidence: `screenshots/task1-budget-alerts.png`, `screenshots/task1-budget-summary.png`.*

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
  --params '{ "listOfAllowedLocations": { "value": ["northeurope","westeurope"] } }'
```
**Validation:** try to create any resource in `eastus` → expect `RequestDisallowedByPolicy`. Screenshot the error — this is the proof the guardrail works.

**Note:** this built-in policy excludes `Microsoft.Resources/resourceGroups` from evaluation by default — it governs the location of *resources inside* a resource group, not the resource group object itself. A separate built-in policy (`Allowed locations for resource groups`, ID `e765b5de-1225-4ba3-bd56-1ac6695af988`) would be needed to also restrict where RGs themselves can be created.

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
Assign the built-in policy **"Inherit a tag from the resource group"** with tag name `CostCenter`. This policy uses the `Modify` effect, which requires a system-assigned managed identity with the `Tag Contributor` role at the assignment scope — otherwise the remediation task will fail with a permission error:

```bash
az policy assignment create --name inherit-costcenter-tag \
  --scope /subscriptions/<SUB_ID> \
  --policy <builtin-policy-id-for-tag-inheritance> \
  --params '{ "tagName": { "value": "CostCenter" } }' \
  --mi-system-assigned \
  --location northeurope \
  --identity-scope /subscriptions/<SUB_ID> \
  --role "Tag Contributor"
```

Create `rg-lab01-governance` with tag `CostCenter=LAB`, deploy any cheap resource inside, and show the tag was applied automatically. Run a remediation task and document it.

### 6. RBAC least privilege
```bash
az group create -n rg-lab01-governance -l northeurope --tags CostCenter=LAB
az role assignment create \
  --assignee teste.rbac@marciomarquesbhgmail.onmicrosoft.com \
  --role "Virtual Machine Contributor" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/rg-lab01-governance
```
Document in the README **why** VM Contributor at RG scope (and not Contributor / not subscription scope).

### 7. Resource lock
```bash
az lock create --name protect-lab01 --lock-type CanNotDelete \
  --resource-group rg-lab01-governance
```
**Note:** the Portal calls this lock type "Delete"; the CLI/ARM name is `CanNotDelete` (the Portal equivalent of "Read-only" is `ReadOnly` in CLI/ARM).

**Validation:** attempt to delete a resource in the RG → expect HTTP 409. Screenshot it. Then document the correct removal workflow (remove lock → delete → re-apply).

## Evidence checklist
- [x] Budget with alerts
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