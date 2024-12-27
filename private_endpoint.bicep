@description('Specifies the location for resource')
param location string

@description('Provide the name of private endpoint')
param private_endpoint_name string

@description('Set of tags')
param tags object

@description('Name of the virtual network resource')
param virtual_network_name string

param serviceToLink string
param groupIds array = []

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: virtual_network_name
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  name: 'default'
  parent: virtualNetwork
}

resource privateEndPoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pep-${private_endpoint_name}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'pep-${private_endpoint_name}'
        properties: {
          privateLinkServiceId: serviceToLink
          groupIds: groupIds
        }
      }
    ]
  }
}

output name string = privateEndPoint.name
output id string = privateEndPoint.id

