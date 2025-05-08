targetScope = 'subscription'

var projectName = 'IngestIQ'

@description('Resource group for the IngestIQ project.')
resource ingestrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: projectName
  location: deployment().location
  tags: {
    project: projectName
  }
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  scope: ingestrg
  params: {
    projectName: projectName
  } 
}
