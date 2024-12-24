import { FunctionAppConfiguration } from 'function_app_type.bicep'
@description('Specifies the location for resource')
param location string

@description('Set of tags')
param tags object

@description('Provide the name of function app')
param function_app_name string

param service_plan_name string

param storage_account_name string

param app_insights_name string

param private_endpoint_name string

param functionAppConfiguration FunctionAppConfiguration

@description('Provide the name of managed identity')
param identity_name string

param subnetId string

param virtualNetworkSubnetId string

module managedIdentity 'managed_identity.bicep' = {
  name: 'managedIdentity'
  params: {
    location: location
    tags: tags
    identity_name: identity_name
  }
}

module functionApp 'function_app.bicep' = {
  name: 'functionApp'
  dependsOn: [
    managedIdentity
  ]
  params: {
    location: location
    tags: tags
    app_insights_name: app_insights_name
    functionAppConfiguration: functionAppConfiguration
    function_app_name: function_app_name
    private_endpoint_name: private_endpoint_name
    service_plan_name: service_plan_name
    storage_account_name: storage_account_name
    subnetId: subnetId
    virtualNetworkSubnetId: virtualNetworkSubnetId
  }
}
