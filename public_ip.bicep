@description('Specifies the location for resource')
param location string

@description('Set of tags')
param tags object

@description('Name of public Ip')
param publicIpName string

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: publicIpName
    }
  }
}

output id string = publicIp.id
output name string = publicIp.name
