
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
