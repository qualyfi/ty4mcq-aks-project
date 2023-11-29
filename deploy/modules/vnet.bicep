param parLocation string
param parInitials string
param parNatgwId string

//VNet
resource resVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'aks-${parInitials}-vnet'
  location: parLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/12'
      ]
    }
    subnets: [
      {
        name: 'AppGwSubnet'
        properties: {
          addressPrefix: '10.1.0.0/16'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.2.0.0/26'
        }
      }
      {
        name: 'SystemNodeSubnet'
        properties: {
          addressPrefix: '10.3.0.0/16'
          natGateway: {
            id: parNatgwId
          }
        }
      }
      {
        name: 'SystemPodSubnet'
        properties: {
          addressPrefix: '10.4.0.0/16'
          natGateway: {
            id: parNatgwId
          }
        }
      }
      {
        name: 'ApplicationNodeSubnet'
        properties: {
          addressPrefix: '10.5.0.0/16'
          natGateway: {
            id: parNatgwId
          }
        }
      }
      {
        name: 'ApplicationPodSubnet'
        properties: {
          addressPrefix: '10.6.0.0/16'
          natGateway: {
            id: parNatgwId
          }
        }
      }
    ]
  }
}

//Outputs
output outAppgwSubnetId string = resVnet.properties.subnets[0].id
output outBastionSubnetId string = resVnet.properties.subnets[1].id

output outSystemVnetSubnetId string = resVnet.properties.subnets[2].id
output outSystemPodSubnetId string = resVnet.properties.subnets[3].id
output outApplicationVnetSubnetId string = resVnet.properties.subnets[4].id
output outApplicationPodSubnetId string = resVnet.properties.subnets[5].id

