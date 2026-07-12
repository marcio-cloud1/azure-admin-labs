### Prerequisite — Test Identity

Created a test user in Microsoft Entra ID to be used as the target for the
RBAC assignment in Task 6 below.

**Command executed:**
```powershell
az ad user create --display-name "Test RBAC AZ104" --user-principal-name "teste.rbac@marciomarquesbhgmail.onmicrosoft.com" --password "SenhaForte#2026!"
```

**Result:** user created successfully (Object ID: `26c446d3-6bf5-40ef-a787-8786848e2090`).

<p align="center">
  <img src="screenshots/01-entra-user-created.png" width="500" />
</p>

---

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

<p align="center">
  <img src="screenshots/task1-budget-alerts.png" width="400" />
  <img src="screenshots/task1-budget-summary.png" width="400" />
</p>
### 2. Management group (✅ completed)
```powershell
az account management-group create --name mg-corp --display-name "Corp"
az account management-group subscription add --name mg-corp --subscription 9c1310f1-b1f5-46bc-ba21-62ce547631aa
```

<p align="center">
  <img src="screenshots/task2-management-group.png" width="500" />
</p>
