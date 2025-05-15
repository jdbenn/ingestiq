param projectName string
param domainName string
var namespace = toLower(projectName)

// https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain-customer-certificate/main.bicep

resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: '${namespace}-frontdoor-profile'
  location: 'global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: '${namespace}-frontdoor-endpoint'
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

//https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/customdomains?pivots=deployment-language-bicep
resource customDomain 'Microsoft.Cdn/profiles/customDomains@2025-04-15' = {
  name: '${namespace}-custom-domain'
  parent: frontDoorProfile
  properties: {
    hostName: domainName
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }
  }
}

output frontDoorProfileId string = frontDoorProfile.id
output frontDoorEndpointId string = frontDoorEndpoint.id
output customDomainName string = customDomain.name
