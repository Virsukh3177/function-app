@description('Specifies the location for resource')
param location string

@description('Set of tags')
param tags object

@description('Provide the name of managed identity')
param identity_name string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: identity_name
  location: location
  tags: tags
}

output id string = managedIdentity.id
output principalId string = managedIdentity.properties.principalId
output name string = managedIdentity.name
