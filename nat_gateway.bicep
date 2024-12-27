@description('Specifies the location for resource')
param location string

@description('Set of tags')
param tags object

@description('Name of public Ip')
param publicIpName string

@description('Name of the NAT gateway resource')
param natGatewayName string

module publicIp 'public_ip.bicep' = {
  name: 'publicIp'
  params: {
    location: location
    tags: tags
    publicIpName: publicIpName
  }
}

resource natGateway 'Microsoft.Network/natGateways@2024-05-01' = {
  name: natGatewayName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
       {
        id: publicIp.outputs.id
       }
    ]
  }
}

output id string = natGateway.id
output name string = natGateway.name


