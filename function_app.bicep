import { FunctionAppConfiguration } from 'function_app_type.bicep'
@description('Specifies the location for resource')
param location string

@description('Set of tags')
param tags object

@description('Provide the name of function app')
param functionAppName string

@description('Name of app service plan')
param servicePlanName string

@description('Name of storage account')
param storageAccountName string

@description('Name of application insight')
param appInsightsName string

@description('Provide the function app configuration')
param functionAppConfiguration FunctionAppConfiguration

param publicNetworkAccess bool = false

param subnetInfo object

var isReserved = (functionAppConfiguration.osType == 'Linux') ? true : false

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: functionAppConfiguration.application_type
    Request_Source: 'rest'
  }
}

resource servicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: servicePlanName
  location: location
  sku: functionAppConfiguration.sku
  properties: {
    reserved: isReserved
  }
}

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: (isReserved ? 'functionapp,linux' : 'functionapp')
  identity: {
     type: functionAppConfiguration.identity.type
  }
  properties: {
    serverFarmId: servicePlan.id
    enabled: true
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    virtualNetworkSubnetId: subnetInfo.id
    hostNameSslStates: [
      {
        name: '${functionAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
    ]
    siteConfig: {
      linuxFxVersion: functionAppConfiguration.teckStack
      alwaysOn: true
      appSettings: [
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionAppConfiguration.worker_runtime
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
      ]
      autoHealEnabled: false
    }
    httpsOnly: true
    vnetRouteAllEnabled: true
  }
}

output id string = functionApp.id
output name string = functionApp.name
