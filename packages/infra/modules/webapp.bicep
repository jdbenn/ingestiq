param projectName string
param nodeVersion string = '20'

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${toLower(projectName)}-webapp-plan'
  location: resourceGroup().location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
    reserved: true
  }
  tags: {
    projectName: projectName
  }
}

resource appService 'Microsoft.Web/sites@2024-04-01' = {
  name: '${toLower(projectName)}-webapp'
  location: resourceGroup().location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|${nodeVersion}'
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: nodeVersion
        }
        {
          name: 'PORT'
          value: '8080'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
    httpsOnly: true
  }
}


resource stagingSlot 'Microsoft.Web/sites/slots@2024-04-01' = {
  parent: appService
  name: 'staging'
  location: resourceGroup().location
  kind: 'app,linux'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|${nodeVersion}'
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: nodeVersion
        }
        {
          name: 'PORT'
          value: '8080'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
    httpsOnly: true
  }
}
