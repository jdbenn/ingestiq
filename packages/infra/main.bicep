
param subscriptionId string

var projectName = 'IngestIQ'

resource ingestrg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'IngestIQ'
  scope: subscription(subscriptionId)
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  scope: ingestrg
  params: {
    projectName: projectName
  } 
}

module function 'modules/function.bicep' = {
  name: 'function'
  scope: ingestrg
  params: {
    functionAppName: 'IngestIQ'
    storageAccountName: storage.outputs.storageAccountName
    projectName: projectName
  }
}

module webapp 'modules/webapp.bicep' = {
  name: 'webapp'
  scope: ingestrg
  params: {
    projectName: projectName
  }
  dependsOn: [
    function
  ]
}


