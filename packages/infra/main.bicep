
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

module frontDoor 'modules/frontdoor.bicep' = {
  name: 'frontdoor'
  scope: resourceGroup
  params: {
    projectName: projectName
    domainName: 'ingestiq.thescreaminggoat.xyz'
  }
}

module function 'modules/function.bicep' = {
  name: 'function'
  scope: resourceGroup
  params: {
    functionAppName: 'IngestIQ'
    storageAccountName: storage.outputs.storageAccountName
    projectName: projectName
    frontDoorProfileId: frontDoor.outputs.frontDoorProfileId
  }
}

module webapp 'modules/webapp.bicep' = {
  name: 'webapp'
  scope: resourceGroup
  params: {
    projectName: projectName
    frontDoorProfileId: frontDoor.outputs.frontDoorProfileId
  }
  dependsOn: [
    function
  ]
}

module frontDoorOrigins 'modules/frontdoor-origins.bicep' = {
  name: 'frontdoor-origins'
  scope: resourceGroup
  params: {
    projectName: projectName
    webAppHost: webapp.outputs.webAppHostName
    apiHost: function.outputs.functionAppHostName
    frontDoorProfileId: frontDoor.outputs.frontDoorProfileId
    frontDoorEndpointId: frontDoor.outputs.frontDoorEndpointId
    customDomainName: frontDoor.outputs.customDomainName
  }
}
