param parLocation string
param parInitials string

module modAksCluster 'modules/akscluster.bicep' = {
  name: 'aksCluster'
  params: {
    parLocation: parLocation
    parInitials: parInitials
  }
}
