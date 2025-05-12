param projectName string
param containerPort int = 4000

resource registry 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: '${toLower(projectName)}-registry'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Disabled'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${projectName}-webapp-plan'
  location: resourceGroup().location
  sku: {
    name: 'B1'
    tier: 'Basic'
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
  kind: 'linux,app,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${registry.name}.azurecr.io/${projectName}-webapp:latest'
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '${containerPort}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${registry.name}.azurecr.io'
        }
      ]
    }
    httpsOnly: true
  }
}

resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appService.id, 'acrpull')
  scope: registry
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    )
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
