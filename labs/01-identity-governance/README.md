# Governance and Identity Lab

Hands-on lab for the AZ-104 "Manage Azure identities and governance" domain, built as a single integrated scenario instead of isolated exercises per topic.

### Prerequisite: Test Identity

Created a test user in Microsoft Entra ID to use later as the target for the RBAC assignment in Task 6.

```powershell
az ad user create --display-name "Test RBAC AZ104" --user-principal-name "teste.rbac@marciomarquesbhgmail.onmicrosoft.com" --password "SenhaForte#2026!"
```

Object ID: `26c446d3-6bf5-40ef-a787-8786848e2090`.

<p align="center">
  <img src="screenshots/01-entra-user-created.png" width="480" />
</p>

---

This lab simulates a common ask from any company before letting teams deploy workloads: spending limits, a locked-down list of allowed regions, mandatory cost-center tags, delete protection on critical resource groups, and a support team that can only touch what it actually needs.

Covers management groups, Azure Policy (a built-in one plus a custom JSON definition I wrote), RBAC, resource locks, tag governance, and budgets. Everything here is a governance object, so no cost, and it took me about 2-3 hours end to end.

## Architecture

```
Tenant Root Group
└── mg-corp (management group)
    └── Subscription (free trial)
        ├── Policy: Allowed locations (Deny) - northeurope, westeurope
        ├── Policy: Inherit CostCenter tag (Modify)
        └── rg-lab01-governance
            ├── Lock: CanNotDelete
            └── Role assignment: Virtual Machine Contributor (scoped here)

Billing Account (Marcio Moreira Marques)
└── Budget: lab-budget1 ($50/month, alerts 50/80/100%)
```

## Tasks

### 1. Budget (Completed)

Created a budget called `lab-budget1` through Cost Management, at the Billing Account scope rather than Subscription (I'd originally planned Subscription, but Cost Management also lets you attach a budget at the Billing Account, Billing Profile, or Resource Group level - Billing Account actually covers any future subscription under this same account, so I kept it). $50/month, resets monthly, alerts at 50% ($25), 80% ($40) and 100% ($50) going to my email.

<p align="center">
  <img src="screenshots/task1-budget-alerts.png" width="420" />
  <img src="screenshots/task1-budget-summary.png" width="420" />
</p>

### 2. Management group (Completed)

```powershell
az account management-group create --name mg-corp --display-name "Corp"
az account management-group subscription add --name mg-corp --subscription 9c1310f1-b1f5-46bc-ba21-62ce547631aa
```

The first command took close to a minute to return, which is apparently normal for the first management group created in a tenant.

<p align="center">
  <img src="screenshots/task2-management-group.png" width="480" />
</p>

### 3. Built-in policy: Allowed locations (Deny) (Completed)

```powershell
az policy assignment create --name allowed-locations --scope /providers/Microsoft.Management/managementGroups/mg-corp --policy e56962a6-4747-49cd-b67b-bf8b01975c4c --params @labs/01-identity-governance/scripts/task3-params.json

az storage account create --name teststoragedeny01 --resource-group rg-lab1 --location eastus --sku Standard_LRS
```

Second command got blocked with `RequestDisallowedByPolicy`, exactly as expected. One thing worth knowing: this built-in policy skips resource groups themselves - it only checks resources created inside one. There's a separate policy, "Allowed locations for resource groups," if you also want to restrict where the RG object itself can live.

<p align="center">
  <img src="screenshots/task3-policy-deny.png" width="480" />
</p>

### 4. Custom policy: audit public blob access (Completed)

Wrote the rule myself in `scripts/policy-audit-public-blob.json`:

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

```powershell
az policy definition create --name audit-public-blob --rules @labs/01-identity-governance/scripts/policy-audit-public-blob.json --mode Indexed
az policy assignment create --name audit-public-blob --scope /subscriptions/9c1310f1-b1f5-46bc-ba21-62ce547631aa --policy audit-public-blob
```

Definition and assignment both went through on the first try. Compliance results can take up to half an hour to show up, so that's still pending a look.

<p align="center">
  <img src="screenshots/task4-custom-policy.png" width="480" />
</p>
