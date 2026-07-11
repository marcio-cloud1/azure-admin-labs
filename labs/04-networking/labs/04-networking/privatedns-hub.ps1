# Cria Private DNS Zone (recurso global, sem -Location)
New-AzPrivateDnsZone -ResourceGroupName "rg-lab1" -Name "contoso.internal"

# Linka a zona à vnet-hub, com autoregistration habilitada
$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-lab1" -Name "vnet-hub"

New-AzPrivateDnsVirtualNetworkLink -ResourceGroupName "rg-lab1" `
  -ZoneName "contoso.internal" -Name "link-hub" `
  -VirtualNetworkId $vnet.Id -EnableRegistration

# Adiciona um registro A manual
$recordConfig = New-AzPrivateDnsRecordConfig -IPv4Address "10.0.1.10"

New-AzPrivateDnsRecordSet -ResourceGroupName "rg-lab1" -ZoneName "contoso.internal" `
  -Name "vm-app01" -RecordType A -Ttl 3600 -PrivateDnsRecords $recordConfig
  