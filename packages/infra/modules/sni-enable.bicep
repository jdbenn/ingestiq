param AppName string
param AppHostName string
param certificateThumbprint string

resource AppCustomHostEnable 'Microsoft.Web/sites/hostNameBindings@2020-06-01' = {
  name: '${AppName}/${AppHostName}'
  properties: {
    sslState: 'SniEnabled'
    thumbprint: certificateThumbprint
  }
}
