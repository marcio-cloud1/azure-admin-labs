# Cria NSG (Network Security Group) com regra de Allow RDP
# Associa o NSG à subnet snet-mgmt da VNet vnet-hub
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName "rg-lab1" -Name "nsg-mgmt" -Location "northeurope"

$nsg | Add-AzNetworkSecurityRuleConfig -Name "allow-rdp" -Priority 100 `
  -Direction Inbound -Access Allow -Protocol Tcp -DestinationPortRange 3389 `
  -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix *

$nsg | Set-AzNetworkSecurityGroup

$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub"
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-mgmt" `
  -AddressPrefix "10.0.1.0/24" -NetworkSecurityGroup $nsg
$vnet | Set-AzVirtualNetwork