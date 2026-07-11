# Corrige overlap de IP: ajusta vnet-hub-ps para range diferente antes do peering
$vnetHubPs = Get-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub-ps"
$vnetHubPs.AddressSpace.AddressPrefixes.Clear()
$vnetHubPs.AddressSpace.AddressPrefixes.Add("10.1.0.0/16")
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetHubPs -Name "snet-mgmt" `
  -AddressPrefix "10.1.1.0/24"
$vnetHubPs | Set-AzVirtualNetwork

# Cria peering bidirecional entre vnet-hub e vnet-hub-ps
$vnetHub = Get-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub"
$vnetHubPs = Get-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub-ps"

Add-AzVirtualNetworkPeering -Name "hub-to-hubps" `
  -VirtualNetwork $vnetHub -RemoteVirtualNetworkId $vnetHubPs.Id

Add-AzVirtualNetworkPeering -Name "hubps-to-hub" `
  -VirtualNetwork $vnetHubPs -RemoteVirtualNetworkId $vnetHub.Id