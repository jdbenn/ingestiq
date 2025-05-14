
param location string = 'centralus'

var projectName = 'IngestIQ'

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: projectName
  location: location
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    projectName: projectName
  } 
}

module function 'modules/function.bicep' = {
  name: 'function'
  scope: resourceGroup
  params: {
    functionAppName: 'IngestIQ'
    storageAccountName: storage.outputs.storageAccountName
    projectName: projectName
  }
}

module webapp 'modules/webapp.bicep' = {
  name: 'webapp'
  scope: resourceGroup
  params: {
    projectName: projectName
    hostName: 'ingestiq.thescreaminggoat.xyz'
  }
  dependsOn: [
    function
  ]
}


