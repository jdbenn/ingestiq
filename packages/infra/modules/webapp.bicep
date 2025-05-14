param projectName string
param nodeVersion string = '22'
param hostName string

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
      appCommandLine: 'node /home/site/wwwroot/dist/server/server.js'
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
    }
    httpsOnly: true
  }
}


resource stagingSlot 'Microsoft.Web/sites/slots@2024-04-01' = {
  parent: webApp
  name: 'staging'
  location: resourceGroup().location
  kind: 'app,linux'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|${nodeVersion}-lts'
      appCommandLine: 'node /home/site/wwwroot/dist/server/server.js'
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

resource customHost 'Microsoft.Web/sites/hostNameBindings@2024-04-01' = {
  parent: webApp
  name: hostName
  properties: {
    hostNameType: 'Verified'
    sslState: 'Disabled'
    customHostNameDnsRecordType: 'CName'
    siteName: webApp.name
  }
}

resource certificate 'Microsoft.Web/certificates@2024-04-01' = {
  name: '${webApp.name}-webapp-cert'
  location: resourceGroup().location
  dependsOn:[
    customHost
  ]
  properties: {
    serverFarmId: hostingPlan.id
    canonicalName: hostName
  }
}

module customHostEnable 'sni-enable.bicep' = {
  name: '${deployment().name}-${webApp.name}-sni-enable'
  params: {
    AppName: webApp.name
    AppHostName: hostName
    certificateThumbprint: certificate.properties.thumbprint
  }
}

resource stagingCustomHost 'Microsoft.Web/sites/slots/hostNameBindings@2024-04-01' = {
  parent: stagingSlot
  name: 'staging.${hostName}'
  properties: {
    hostNameType: 'Verified'
    sslState: 'Disabled'
    customHostNameDnsRecordType: 'CName'
    siteName: stagingSlot.name
  }
}

resource stagingCertificate 'Microsoft.Web/certificates@2024-04-01' = {
  name: '${stagingSlot.name}-webapp-cert'
  location: resourceGroup().location
  dependsOn:[
    stagingCustomHost
  ]
  properties: {
    serverFarmId: hostingPlan.id
    canonicalName: 'staging.${hostName}'
  }
}

module stagingHostEnable 'sni-enable.bicep' = {
  name: '${deployment().name}-${stagingSlot.name}-sni-enable'
  params: {
    AppName: '${webApp.name}/staging'
    AppHostName: 'staging.${hostName}'
    certificateThumbprint: stagingCertificate.properties.thumbprint
  }
}
