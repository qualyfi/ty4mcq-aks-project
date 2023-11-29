param parLocation string
param parInitials string
param parBastionSubnetId string

//Bastion Public IP
resource resBasPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'aks-${parInitials}-bas-pip'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//Bastion
resource resBas 'Microsoft.Network/bastionHosts@2023-05-01' = {
  name: 'aks-${parInitials}-bas'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod:'Dynamic'
          publicIPAddress: {
            id: resBasPublicIP.id
          }
          subnet: {
            id: parBastionSubnetId
          }
        }
      }
    ]
  }
}
