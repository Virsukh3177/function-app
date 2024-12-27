import { FunctionAppConfiguration } from 'function_app_type.bicep'
@description('Specifies the location for resource')
param location string

@description('Set of tags')
param tags object

@description('Name of the virtual network resource')
param virtualNetworkName string

@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('Provide the name of function app')
param functionAppName string

@description('Name of app service plan')
param servicePlanName string

@description('Name of storage account')
param storageAccountName string

@description('Name of application insight')
param appInsightsName string

@description('Name of public Ip')
param publicIpName string

@description('Name of the NAT gateway resource')
param natGatewayName string

@description('Provide the function app configuration')
param functionAppConfiguration FunctionAppConfiguration

@description('Provide the name of managed identity')
param identityName string

func transfromToObject(obj array) object =>
  toObject(obj, entry => '${entry.name}', entry => entry)

var subnetsInfo = transfromToObject(virtualNetwork.outputs.subnetInfo)
output subnetsInfo object = subnetsInfo.default


module managedIdentity 'managed_identity.bicep' = {
  name: 'managedIdentity'
  params: {
    location: location
    identityName: identityName
    tags: tags
  }
}

module natGateway 'nat_gateway.bicep' = {
  name: 'natGateway'
  params: {
    location: location
    natGatewayName: natGatewayName
    publicIpName: publicIpName
    tags: tags
  }
}

module virtualNetwork 'vnet.bicep' = {
  name: 'virtualNetwork'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    vnetAddressPrefix: vnetAddressPrefix
    natGatewayName: natGateway.outputs.name
    tags: tags
  }
}

module functionApp 'function_app.bicep' = {
  name: 'functionApp'
  dependsOn: [
    managedIdentity
  ]
  params: {
    location: location
    appInsightsName: appInsightsName
    functionAppConfiguration: functionAppConfiguration
    functionAppName: functionAppName
    servicePlanName: servicePlanName
    storageAccountName: storageAccountName
    subnetInfo: subnetsInfo['func-subnet']
    tags: tags
  }
}


