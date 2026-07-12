# Cria Application Gateway (Standard_v2) com listener HTTP basico e
# regra de roteamento simples, demonstrando os componentes centrais do recurso.
#
# ATENCAO: Application Gateway NAO possui SKU gratuito. Cobra por hora de
# provisionamento. Deploy leva ~15-20 min. Recomenda-se remover logo apos
# validacao (comandos de limpeza no final deste script).

# 1. Cria subnet dedicada e exclusiva para o Application Gateway
$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub"

Add-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-appgw" `
  -AddressPrefix "10.0.2.0/24"

$vnet | Set-AzVirtualNetwork

# 2. Cria o Public IP (obrigatorio para o Application Gateway)
$pip = New-AzPublicIpAddress -ResourceGroupName "rg-lab1" -Name "pip-appgw" `
  -Location "northeurope" -AllocationMethod Static -Sku Standard

# 3. Monta os componentes do gateway
$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub"
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "snet-appgw"

$gipconfig = New-AzApplicationGatewayIPConfiguration -Name "gwipconfig" -Subnet $subnet
$fipconfig = New-AzApplicationGatewayFrontendIPConfig -Name "fe-appgw" -PublicIPAddress $pip
$fp = New-AzApplicationGatewayFrontendPort -Name "port80" -Port 80
$pool = New-AzApplicationGatewayBackendAddressPool -Name "be-appgw"
$poolSettings = New-AzApplicationGatewayBackendHttpSettings -Name "httpsettings" `
  -Port 80 -Protocol Http -CookieBasedAffinity Disabled
$listener = New-AzApplicationGatewayHttpListener -Name "listener-http" `
  -Protocol Http -FrontendIPConfiguration $fipconfig -FrontendPort $fp
$rule = New-AzApplicationGatewayRequestRoutingRule -Name "rule-basic" `
  -RuleType Basic -HttpListener $listener -BackendAddressPool $pool `
  -BackendHttpSettings $poolSettings -Priority 100
$sku = New-AzApplicationGatewaySku -Name "Standard_v2" -Tier "Standard_v2" -Capacity 1

# 4. Cria o Application Gateway (deploy demorado, ~15-20 min)
New-AzApplicationGateway -ResourceGroupName "rg-lab1" -Name "appgw-web" `
  -Location "northeurope" -GatewayIPConfigurations $gipconfig `
  -FrontendIPConfigurations $fipconfig -FrontendPorts $fp `
  -BackendAddressPools $pool -BackendHttpSettingsCollection $poolSettings `
  -HttpListeners $listener -RequestRoutingRules $rule -Sku $sku

# 5. Confirma criacao
Get-AzApplicationGateway -ResourceGroupName "rg-lab1" -Name "appgw-web"

# ---------------------------------------------------------------------------
# LIMPEZA (rodar logo apos validar, para minimizar custo de hora ativa)
# ---------------------------------------------------------------------------
# Remove-AzApplicationGateway -ResourceGroupName "rg-lab1" -Name "appgw-web" -Force
# Remove-AzPublicIpAddress -ResourceGroupName "rg-lab1" -Name "pip-appgw" -Force
