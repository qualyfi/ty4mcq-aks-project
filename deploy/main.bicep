param parLocation string
param parInitials string
param parTenantId string
param parEntraGroupId string
param parAcrName string
param parUserId string
param parSshPublicKey string

module modAksCluster 'modules/akscluster.bicep' = {
  name: 'aksCluster'
  params: {
    parLocation: parLocation
    parInitials: parInitials
    parTenantId: parTenantId
    parEntraGroupId: parEntraGroupId
    parAppgwName: 'aks-${parInitials}-appgw'
    parAcrName: parAcrName
    parUserId: parUserId
    parAksClusterAdminUsername: 'ty4mcq'
    parSshPublicKey: parSshPublicKey
    parExampleSecretName: 'ExampleSecret'
    parExampleSecretValue: 'idkmayn'
  }
}
