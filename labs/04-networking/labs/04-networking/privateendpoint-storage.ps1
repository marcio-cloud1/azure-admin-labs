# Cria Private Endpoint apontando para a Storage Account (storagebashpowershell),
# conectado ao grupo "blob", dentro da subnet snet-mgmt da vnet-hub.

$storageAccount = Get-AzStorageAccount -ResourceGroupName "rg-lab1" -Name "storagebashpowershell"

$pls = New-AzPrivateLinkServiceConnection -Name "conn-storage" `
  -PrivateLinkServiceId $storageAccount.Id -GroupId "blob"

$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub"
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-mgmt"

New-AzPrivateEndpoint -ResourceGroupName "rg-lab1" -Name "pe-storage" `
  -Location "northeurope" -Subnet $subnet -PrivateLinkServiceConnection $pls

# Limpeza (rodar apos validacao)
# Remove-AzPrivateEndpoint -ResourceGroupName "rg-lab1" -Name "pe-storage" -Force
