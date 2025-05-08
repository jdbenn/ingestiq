param projectName string

var project = toLower(projectName)

resource ingestStorageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: '${project}storage'
  location: az.resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
  tags: {
    projectName: projectName
  }
}

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2024-01-01' = {
  parent: ingestStorageAccount
  name: 'default'
}

resource ingestQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2024-01-01' = {
  name: '${project}queue'
  parent: queueService
  properties: {
    metadata: {
      queueName: '${project}queue'
    }
  }
}

output storageAccountName string = ingestStorageAccount.name
