# Cria Route Table (UDR) forçando saída via firewall virtual (NVA)
# Associa a Route Table à subnet snet-mgmt da VNet vnet-hub
$route = New-AzRouteConfig -Name "force-firewall" -AddressPrefix "0.0.0.0/0" `
  -NextHopType VirtualAppliance -NextHopIpAddress "10.0.2.4"

$routeTable = New-AzRouteTable -ResourceGroupName "rg-lab1" -Name "rt-mgmt" `
  -Location "northeurope" -Route $route

$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub"
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-mgmt" `
  -AddressPrefix "10.0.1.0/24" -RouteTable $routeTable
$vnet | Set-AzVirtualNetwork