@description('Specifies the location for resource')
param location string

@description('Provide the name of private endpoint')
param private_endpoint_name string

param serviceToLink string
param groupIds array = []

@description('Set of tags')
param tags object

param subnetId string

resource privateEndPoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pep-${private_endpoint_name}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
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

