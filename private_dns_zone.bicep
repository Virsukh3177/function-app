@description('Provide the name of private endpoint')
param private_endpoint_name string

@description('Name of private dns zone')
param private_dns_zone_name string

@description('Name of private endpoint dns group')
param private_endpoint_dns_group string

@description('Name of the virtual network resource')
param virtual_network_name string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: virtual_network_name
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' existing = {
  name: private_endpoint_name
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: private_dns_zone_name
  location: 'global'
  properties: {}
}

resource vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'vnetLink'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetwork.id
    }
    registrationEnabled: false
  }
}

resource privateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  parent: privateEndpoint
  name: private_endpoint_dns_group
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
