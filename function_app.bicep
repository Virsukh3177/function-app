import { FunctionAppConfiguration } from 'function_app_type.bicep'
@description('Specifies the location for resource')
param location string

@description('Set of tags')
param tags object

@description('Provide the name of function app')
param function_app_name string

@description('Name of app service plan')
param service_plan_name string

@description('Name of storage account')
param storage_account_name string

@description('Name of application insight')
param app_insights_name string

param private_endpoint_name string

param functionAppConfiguration FunctionAppConfiguration

param subnetId string

param virtualNetworkSubnetId string

param publicNetworkAccess bool = false

var isReserved = (functionAppConfiguration.osType == 'Linux') ? true : false

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storage_account_name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: app_insights_name
  location: location
  kind: 'web'
  properties: {
    Application_Type: functionAppConfiguration.application_type
    Request_Source: 'rest'
  }
}

resource servicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: service_plan_name
  location: location
  sku: functionAppConfiguration.sku
  properties: {
    reserved: isReserved
  }
}

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: function_app_name
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
    virtualNetworkSubnetId: virtualNetworkSubnetId
    hostNameSslStates: [
      {
        name: '${function_app_name}.azurewebsites.net'
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
          value: toLower(function_app_name)
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
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage_account_name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage_account_name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
      ]
      autoHealEnabled: false
    }
    httpsOnly: true
    vnetRouteAllEnabled: true
  }
}

module privateEndpoint 'private_endpoint.bicep' = {
  name: 'privateEndpoint'
  params: {
    location: location
    tags: tags
    private_endpoint_name: private_endpoint_name
    serviceToLink: functionApp.id
    groupIds: [
      'sites'
    ]
    subnetId: subnetId
  }
}
