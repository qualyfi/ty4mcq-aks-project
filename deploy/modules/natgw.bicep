param parLocation string
param parInitials string

//NAT GW Public IP
resource resNatGwPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'aks-${parInitials}-natgw-pip'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//NAT GW
resource resNatGw 'Microsoft.Network/natGateways@2023-05-01' = {
  name: 'aks-${parInitials}-natgw'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIpAddresses: [
      {
        id: resNatGwPublicIP.id
      }
    ]
  }
}

//Outputs
output outNatgwId string = resNatGw.id
