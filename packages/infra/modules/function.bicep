param functionAppName string
param storageAccountName string
param projectName string
param frontDoorProfileId string

var hostingPlanName = '${functionAppName}-functionapp-plan'

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: storageAccountName
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2025-04-15' existing = {
  name: last(split(frontDoorProfileId, '/'))
}

var frontDoorFdid = frontDoorProfile.properties.frontDoorId

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: toLower(hostingPlanName)
  location: resourceGroup().location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
  tags: {
    projectName: projectName
  }
}

var storageKey = storageAccount.listKeys().keys[0].value
var azureWebJobsStorage = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageKey};EndpointSuffix=core.windows.net'

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: '${toLower(functionAppName)}-functionapp'
  location: resourceGroup().location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|22'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: azureWebJobsStorage
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
      ]
      ipSecurityRestrictions:[
        {
          ipAddress: 'AzureFrontDoor.Backend'
          tag: 'ServiceTag'
          action: 'Allow'
          priority: 100
          name: 'Allow Azure Front Door Traffic'
          headers: {
            'x-azure-fdid': [ frontDoorFdid ]
          }
        }
      ]
    }
    httpsOnly: true
  }
  
}


resource stagingSlot 'Microsoft.Web/sites/slots@2024-04-01' = {
  parent: functionApp
  name: 'staging'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|22'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: azureWebJobsStorage
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
      ]
    }
    httpsOnly: true
  }
}

output functionAppHostName string = functionApp.properties.defaultHostName
