# Cria Internal Load Balancer (SKU Basic, gratuito) com health probe HTTP
$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub"
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-mgmt"

$feip = New-AzLoadBalancerFrontendIpConfig -Name "fe-internal" `
  -PrivateIpAddress "10.0.1.100" -SubnetId $subnet.Id

$bepool = New-AzLoadBalancerBackendAddressPoolConfig -Name "be-internal"

$probe = New-AzLoadBalancerProbeConfig -Name "probe-http" -Protocol Tcp -Port 80 `
  -IntervalInSeconds 15 -ProbeCount 2

$rule = New-AzLoadBalancerRuleConfig -Name "rule-http" -Protocol Tcp `
  -FrontendPort 80 -BackendPort 80 `
  -FrontendIpConfiguration $feip -BackendAddressPool $bepool -Probe $probe

New-AzLoadBalancer -ResourceGroupName "rg-lab1" -Name "lb-internal" `
  -Location "northeurope" -Sku "Basic" `
  -FrontendIpConfiguration $feip -BackendAddressPool $bepool `
  -Probe $probe -LoadBalancingRule $rule

# Limpeza (recurso deletado após validação, boa prática de custo)
# Remove-AzLoadBalancer -ResourceGroupName "rg-lab1" -Name "lb-internal" -Force
