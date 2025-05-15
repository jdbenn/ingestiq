param projectName string
param nodeVersion string = '22'
param frontDoorProfileId string

resource frontDoorProfile 'Microsoft.Cdn/profiles@2025-04-15' existing = {
  name: last(split(frontDoorProfileId, '/'))
}

var frontDoorFdid = frontDoorProfile.properties.frontDoorId

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

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${toLower(projectName)}-webapp-insights'
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
  tags: {
    projectName: projectName
  }
}

var startCommand = 'node /home/site/wwwroot/dist/web/server/server.mjs'

resource webApp 'Microsoft.Web/sites@2024-04-01' = {
  name: '${toLower(projectName)}-webapp'
  location: resourceGroup().location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      nodeVersion: nodeVersion
      linuxFxVersion: 'NODE|${nodeVersion}-lts'
      appCommandLine: startCommand
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
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATION_INSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'APPINSIGHTS_ROLE_NAME'
          value: 'webapp'
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
  parent: webApp
  name: 'staging'
  location: resourceGroup().location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|${nodeVersion}-lts'
      appCommandLine: startCommand
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
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATION_INSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'APPINSIGHTS_ROLE_NAME'
          value: 'webapp-staging'
        }
      ]
    }
    httpsOnly: true
  }
}

output webAppHostName string = webApp.properties.defaultHostName
