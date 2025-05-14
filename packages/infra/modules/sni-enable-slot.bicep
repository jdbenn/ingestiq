param AppName string
param SlotName string
param HostName string
param certificateThumbprint string

resource hostBinding 'Microsoft.Web/sites/slots/hostNameBindings@2020-06-01' = {
  name: '${AppName}/${SlotName}/${HostName}'
  properties: {
    sslState: 'SniEnabled'
    thumbprint: certificateThumbprint
  }
}
