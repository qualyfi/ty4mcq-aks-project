param parLocation string
param parInitials string
param parTenantId string
param parEntraGroupId string
param parAcrName string
param parUserId string
param parSshPublicKey string
param parAksClusterName string
param parAksClusterAdminUsername string

module modAksCluster 'modules/akscluster.bicep' = {
  name: 'aksCluster'
  params: {
    parLocation: parLocation
    parInitials: parInitials
    parTenantId: parTenantId
    parEntraGroupId: parEntraGroupId
    parAksClusterAdminUsername: parAksClusterAdminUsername
    parSshPublicKey: parSshPublicKey
    parAksClusterName: parAksClusterName
    parLawId: modLaw.outputs.outLawId
    parSystemVnetSubnetId: modVnet.outputs.outSystemVnetSubnetId
    parSystemPodSubnetId: modVnet.outputs.outSystemPodSubnetId
    parApplicationVnetSubnetId: modVnet.outputs.outApplicationVnetSubnetId
    parApplicationPodSubnetId: modVnet.outputs.outApplicationPodSubnetId
    parAppgwId: modAppgw.outputs.outAppgwId
  }
}

module modAcr 'modules/acr.bicep' = {
  name: 'acr'
  params: {
    parLocation: parLocation
    parAcrName: parAcrName
  }
}

module modAppgw 'modules/appgw.bicep' = {
  name: 'appgw'
  params: {
    parLocation: parLocation
    parInitials: parInitials
    parAppgwName: 'aks-${parInitials}-appgw'
    parAppgwSubnetId: modVnet.outputs.outAppgwSubnetId
  }
}

module modBastion 'modules/bastion.bicep' = {
  name: 'bastion'
  params: {
    parLocation: parLocation
    parInitials: parInitials
    parBastionSubnetId: modVnet.outputs.outBastionSubnetId
  }
}

module modMetrics 'modules/metrics.bicep' = {
  name: 'metrics'
  params: {
    parLocation: parLocation
    parInitials: parInitials
    parLawId: modLaw.outputs.outLawId
    parAksClusterName: modAksCluster.outputs.outAksClusterName
  }
}

module modNatgw 'modules/natgw.bicep' = {
  name: 'natgw'
  params: {
    parLocation: parLocation
    parInitials: parInitials
  }
}

module modVnet 'modules/vnet.bicep' = {
  name: 'vnet'
  params: {
    parLocation: parLocation
    parInitials: parInitials
    parNatgwId: modNatgw.outputs.outNatgwId
  }
}

module modLaw 'modules/law.bicep' = {
  name: 'law'
  params: {
    parLocation: parLocation
    parInitials: parInitials
  }
}

module modRoleAssignments 'modules/roleassignments.bicep' = {
  name: 'roleAssignments'
  params: {
    parUserId: parUserId
    parAksClusterId: modAksCluster.outputs.outAksClusterId
    parAksClusterObjectId: modAksCluster.outputs.outAksClusterObjectId
    parAppgwId: modAppgw.outputs.outAppgwId
    parAcrId: modAcr.outputs.outAcrId
    parAcrName: modAcr.outputs.outAcrName
    parGrafanaName: modMetrics.outputs.outGrafanaName
    parPrometheusName: modMetrics.outputs.outPrometheusName
  }
}
