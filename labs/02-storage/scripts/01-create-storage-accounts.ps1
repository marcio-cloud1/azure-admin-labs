$suffix = Get-Random -Maximum 99999

az group create -n rg-lab02-storage -l northeurope --tags CostCenter=LAB

$storageLogsName = "stlab02logs43470"

az storage account create -n $storageLogsName -g rg-lab02-storage `
  -l northeurope --sku Standard_RAGRS --kind StorageV2 `
  --min-tls-version TLS1_2 --allow-blob-public-access false

  $suffix = Get-Random -Maximum 99999

az group create -n rg-lab02-storage -l northeurope --tags CostCenter=LAB

$storageLogsName = "stlab02logs43470"

az storage account create -n $storageLogsName -g rg-lab02-storage `
  -l northeurope --sku Standard_RAGRS --kind StorageV2 `
  --min-tls-version TLS1_2 --allow-blob-public-access false

$storageFilesName = "stlab02files43470"

az storage account create -n $storageFilesName -g rg-lab02-storage `
  -l northeurope --sku Standard_GRS --kind StorageV2 `
  --min-tls-version TLS1_2 --allow-blob-public-access false

