param parLocation string
param parInitials string
param parAppgwName string
param parAppgwSubnetId string


//App GW Public IP
resource resAppgwPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'aks-${parInitials}-appgw-pip'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//App GW Managed Identity + Role Assignments
resource resAppGwIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'aks-${parInitials}-appgw-identity'
  location: parLocation
}


//App GW + App GW WAF
resource resAppgw 'Microsoft.Network/applicationGateways@2023-05-01' = {
  name: 'aks-${parInitials}-appgw'
  location: parLocation
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          subnet: {
            id: parAppgwSubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendPIP'
        properties: {
          publicIPAddress: {
            id: resAppgwPublicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bepool-akscluster'
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'bepool-settings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
        }
      }
    ]
    httpListeners: [
      {
        name: 'http-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', parAppgwName, 'frontendPIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', parAppgwName, 'port_80')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'http-only'
        properties: {
          ruleType: 'Basic'
          priority: 1000
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', parAppgwName, 'http-listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', parAppgwName, 'bepool-akscluster')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', parAppgwName, 'bepool-settings')
          }
        }
      }
    ]
    // firewallPolicy: {
    //   id: resAppgwWaf.id
    // }
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resAppGwIdentity.id}': {
      }
    }
  }
}
// resource resAppgwWaf 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-05-01' = {
//   name: 'aks-${parInitials}-appgw-waf'
//   location: parLocation
//   properties: {
//     policySettings: {
//       requestBodyCheck: true
//       maxRequestBodySizeInKb: 128
//       fileUploadLimitInMb: 100
//       state: 'Enabled'
//       mode: 'Detection'
//     }
//     managedRules: {
//       managedRuleSets: [
//         {
//           ruleSetType: 'OWASP'
//           ruleSetVersion: '3.2'
//         }
//       ]
//     }
//   }
// }

//Outputs
output outAppgwId string = resAppgw.id

