param parLocation string
param parAcrName string

//ACR
resource resAcr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: parAcrName
  location: parLocation
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

//Outputs
output outAcrName string = resAcr.name
output outAcrId string = resAcr.id
