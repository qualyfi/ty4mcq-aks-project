param parLocation string
param parInitials string
param parTenantId string
param parEntraGroupId string

module modAksCluster 'modules/akscluster.bicep' = {
  name: 'aksCluster'
  params: {
    parLocation: parLocation
    parInitials: parInitials
    parTenantId: parTenantId
    parEntraGroupId: parEntraGroupId
  }
}
