param projectName string
param webAppHost string
param apiHost string
param frontDoorProfileId string
param frontDoorEndpointId string
param customDomainName string
var namespace = toLower(projectName)

resource frontDoorProfile 'Microsoft.Cdn/profiles@2025-04-15' existing = {
  name: last(split(frontDoorProfileId, '/'))
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2025-04-15' existing = {
  name: last(split(frontDoorEndpointId, '/'))
  parent: frontDoorProfile
}

resource customDomain 'Microsoft.Cdn/profiles/customDomains@2025-04-15' existing = {
  name: customDomainName
  parent: frontDoorProfile
}

resource webAppOriginGroup 'Microsoft.Cdn/profiles/originGroups@2025-04-15' = {
  name: '${namespace}-webapp-origin-group'
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeIntervalInSeconds: 120
      probeProtocol: 'Https'
    }
  }
}

resource webAppOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2025-04-15' = {
  name: '${namespace}-webapp-origin'
  parent: webAppOriginGroup
  properties: {
    hostName: webAppHost
    originHostHeader: webAppHost
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 100
  }
}

resource webAppRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2025-04-15' = {
  name: '${namespace}-webapp-route'
  parent: frontDoorEndpoint
  dependsOn: [
    webAppOrigin
  ]
  properties: {
    enabledState: 'Enabled'
    customDomains: [
      {
        id: customDomain.id
      }
    ]
    originGroup: {
      id: webAppOriginGroup.id
    }
    supportedProtocols: [
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    cacheConfiguration: {
      queryStringCachingBehavior: 'IgnoreQueryString'
    }
  }
}

resource functionAppOriginGroup 'Microsoft.Cdn/profiles/originGroups@2025-04-15' = {
  name: '${namespace}-function-origin-group'
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/api'
      probeRequestType: 'HEAD'
      probeIntervalInSeconds: 120
      probeProtocol: 'Https'
    }
  }
}

resource functionAppOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2025-04-15' = {
  name: '${namespace}-function-origin'
  parent: functionAppOriginGroup
  properties: {
    hostName: apiHost
    originHostHeader: apiHost
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 100
  }
}

resource functionAppRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2025-04-15' = {
  name: '${namespace}-function-route'
  parent: frontDoorEndpoint
  dependsOn: [
    functionAppOrigin
  ]
  properties: {
    enabledState: 'Enabled'
    customDomains: [
      {
        id: customDomain.id
      }
    ]
    originGroup: {
      id: functionAppOriginGroup.id
    }
    supportedProtocols: [
      'Https'
    ]
    patternsToMatch: [
      '/api/*'
    ]
    cacheConfiguration: {
      queryStringCachingBehavior: 'IgnoreQueryString'
    }
  }
}
