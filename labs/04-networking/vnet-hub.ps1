# Cria VNet hub (versão PowerShell) com subnet de gerenciamento
# Mesmo conceito do lab em Bash (vnet-hub), nome diferente para evitar conflito de recurso
$subnet = New-AzVirtualNetworkSubnetConfig -Name "snet-mgmt" -AddressPrefix "10.0.1.0/24"

New-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub-ps" `
  -AddressPrefix "10.0.0.0/16" -Location "northeurope" -Subnet $subnet