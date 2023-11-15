param parLocation string
param parInitials string
param parTenantId string
param parEntraGroupId string

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
        name: 'aksCluster'
        properties: {
          addressPrefix: '10.1.0.0/16'
          natGateway: {
            id: resNatGw.id
          }
        }
      }
      {
        name: 'appGw'
        properties: {
          addressPrefix: '10.2.0.0/16'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.3.0.0/26'
        }
      }
    ]
  }
}

resource resAksCluster 'Microsoft.ContainerService/managedClusters@2023-09-01' = {
  name: 'aks-${parInitials}-akscluster-001'
  location: parLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.26.6'
    dnsPrefix: 'aks-${parInitials}-akscluster-001-dns'
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'system'
        count: 1
        vmSize: 'Standard_DS2_v2'
        maxPods: 30
        maxCount: 20
        minCount: 1
        enableAutoScaling: true
        osType: 'Linux'
        osSKU: 'CBLMariner'
        mode: 'System'
        vnetSubnetID: resVnet.properties.subnets[0].id
      }
      {
        name: 'application'
        count: 1
        vmSize: 'Standard_DS2_v2'
        maxPods: 30
        maxCount: 20
        minCount: 1
        enableAutoScaling: true
        osType: 'Linux'
        osSKU: 'CBLMariner'
        mode: 'System'
        vnetSubnetID: resVnet.properties.subnets[0].id
      }
    ]
    aadProfile: {
      managed: true
      adminGroupObjectIDs: [
        parEntraGroupId
      ]
      tenantID: parTenantId
    }
    disableLocalAccounts: true
  }
}

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
resource resBasPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'aks-${parInitials}-baspip'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
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
            id: resVnet.properties.subnets[2].id
          }
        }
      }
    ]
  }
}
