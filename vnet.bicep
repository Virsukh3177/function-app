@description('Specifies the location for resource')
param location string

@description('Set of tags')
param tags object = {}

@description('Name of the virtual network resource')
param virtualNetworkName string

@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('Name of the NAT gateway resource')
param natGatewayName string

resource natGateway 'Microsoft.Network/natGateways@2024-05-01' existing = {
  name: natGatewayName
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

var subnetsInfo = [
  {
    name: 'default'
    addressPrefix: '192.168.0.0/24'
    serviceEndpoints: []
    delegations: []
    natGateway: null
  }

  {
    name: 'func-subnet'
    addressPrefix: '192.168.1.0/24'
    serviceEndpoints: []
    delegations: [
      {
         name: 'delegation'
         properties: {
            serviceName: 'Microsoft.Web/serverfarms'
          }
      }
    ]
    natGateway: {
      id: natGateway.id
    }
  }
]

resource subnets 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = [for subnet in subnetsInfo :{
  name: subnet.name
  parent: virtualNetwork
  properties: {
   addressPrefix: subnet.addressPrefix
   privateEndpointNetworkPolicies: 'Enabled'
   privateLinkServiceNetworkPolicies: 'Enabled'
   serviceEndpoints: subnet.serviceEndpoints
   delegations: subnet.delegations
   natGateway: subnet.natGateway
  }
}]

output id string = virtualNetwork.id
output name string = virtualNetwork.name
output subnetInfo array = [for i in range(0, length(subnetsInfo)): {
  id: subnets[i].id
  name: subnets[i].name
}]

