# Lab 02 — Secured Storage Platform

This lab sets up a storage platform for a company that keeps application logs and a departmental file share in Azure. The requirements are straightforward but layered: access has to be restricted to the internal network, old logs need to age out and get deleted automatically, data has to stay readable if the region goes down, and external partners occasionally need read access to a file or two without ever touching an account key. Building this out covers storage account replication (LRS, ZRS, GRS, RA-GRS), combining firewall rules with a VNet service endpoint, writing a lifecycle management policy in JSON, mounting an Azure Files share over SMB, generating a time-limited SAS token, and moving files with AzCopy. Total cost stays under a dollar if the resource group gets deleted within the week, and the whole thing takes somewhere around two to three hours.

## Architecture

```
rg-lab02-storage (northeurope)
├── vnet-lab02 / snet-app  -- service endpoint: Microsoft.Storage
├── stlab02logs<unique>    (StorageV2, RA-GRS)
│   ├── container: logs    (firewall: snet-app only)
│   └── lifecycle rule: Cool @30d -> Delete @365d
└── stlab02files<unique>   (Azure Files share: dept-share)
```

