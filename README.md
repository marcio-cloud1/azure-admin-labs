# Azure Administrator Portfolio — Hands-On Labs

Five documented, reproducible labs covering the full scope of the **AZ-104 (Microsoft Azure Administrator)** skill set. Every lab was built in a live Azure subscription, executed through **Portal, Azure CLI and PowerShell**, and torn down with documented cleanup scripts.

**Certified AZ-900 and AWS CLF-C02 · AZ-104 in progress · Based in the Netherlands · Open to Azure administration roles (English-speaking environments)**

---

## Why this portfolio exists

Certifications prove knowledge; this repository proves **practice**. Each lab contains:

- An architecture diagram and a stated business scenario
- Step-by-step implementation (Portal + CLI + PowerShell)
- Validation evidence (screenshots + command output)
- A cost analysis and a full cleanup script
- A "what broke and how I fixed it" section — real troubleshooting notes

## The labs

| # | Lab | AZ-104 domain | Core skills demonstrated |
|---|---|---|---|
| 01 | [Identity & Governance as Code](./labs/01-identity-governance) | Manage identities and governance (20–25%) | Management groups, custom Azure Policy (JSON), RBAC least privilege, locks, tag inheritance, budgets |
| 02 | [Secured Storage Platform](./labs/02-storage) | Implement and manage storage (15–20%) | Storage firewall + service endpoints, replication tiers, lifecycle management, Azure Files, SAS |
| 03 | [Compute Deployment Three Ways](./labs/03-compute) | Deploy and manage compute (20–25%) | VM deployment via Portal/CLI/PowerShell/Bicep, availability zones, VM Scale Sets with autoscale, resize workflow |
| 04 | [Hub-Spoke Network](./labs/04-networking) | Configure and manage virtual networking (15–20%) | Global VNet peering, layered NSGs, private DNS zones, Azure Bastion, Standard Load Balancer |
| 05 | [Backup, Recovery & Monitoring](./labs/05-backup-monitoring) | Monitor and maintain resources (10–15%) | Recovery Services vault (GRS + Cross-Region Restore), restore drill, soft delete, action groups, KQL |

Supporting folders: `scripts/` holds reusable PowerShell and Azure CLI blocks shared across labs, and `final-project/` is an end-to-end capstone combining identity, networking, compute, storage, and monitoring.

## Conventions used across all labs

- **Naming:** `rg-lab<NN>-<purpose>`, resources prefixed by type (`vnet-`, `nsg-`, `vm-`, `st`)
- **Region:** West Europe (primary), North Europe (secondary/DR)
- **Cost discipline:** every lab ends with `az group delete`; a subscription budget with alert at 50/80/100% was configured in Lab 01 before any resource was deployed
- **Idempotency:** CLI/PowerShell blocks can be re-run safely where possible

## Tech stack

Azure Portal · Azure CLI (`az`) · Azure PowerShell (`Az` module) · Bicep · Terraform · Git / GitHub

## About me

Azure Administrator focused on infrastructure operations: identity, networking, storage, compute and business continuity. Certified AZ-900 and AWS CLF-C02; AZ-104 in progress. I value structured, well-documented environments and reproducible work.

> Each lab folder is self-contained. Start with **Lab 01** — it creates the governance guardrails the other labs run under.

## Contact

- **Email:** marciomarquesbh@gmail.com
- **LinkedIn:** [Márcio Moreira Marques](https://www.linkedin.com/in/márcio-moreira-marques-5113a7215)guardrails the other labs run under.
