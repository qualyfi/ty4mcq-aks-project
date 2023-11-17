param parLocation string
param parInitials string
param parTenantId string
param parEntraGroupId string
param parAcrName string

module modAksCluster 'modules/akscluster.bicep' = {
  name: 'aksCluster'
  params: {
    parLocation: parLocation
    parInitials: parInitials
    parTenantId: parTenantId
    parEntraGroupId: parEntraGroupId
    parAppgwName: 'aks-${parInitials}-appgw'
    parAcrName: parAcrName
  }
}
