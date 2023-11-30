param parUserId string
param parAcrId string
param parAksClusterObjectId string
param parAppgwId string
param parAksClusterId string
param parAcrName string
param parPrometheusName string
param parGrafanaName string



var varAcrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
var varAppGwNetContributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
var varAppGwContributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var varMonitoringReaderRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '43d0d8ad-25c7-4714-9337-8ba259a9fe05')
var varMonitoringDataReaderRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b0d8363b-8ddd-447d-831f-62ca05bff136')
var varGrafanaAdminRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '22926164-76b3-42b3-bc55-97df8dab3e41')

//Declaring Existing Resources
resource resAcr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: parAcrName
}
resource resMspromMonitorWorkspace 'Microsoft.Monitor/accounts@2023-04-03' existing = {
  name: parPrometheusName
}
resource resGrafana 'Microsoft.Dashboard/grafana@2022-08-01' existing = {
  name: parGrafanaName
}

//ACR Role Assignment
resource resAcrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, parAcrId, varAcrPullRoleDefinitionId)
  scope: resAcr
  properties: {
    principalId: parAksClusterObjectId
    roleDefinitionId: varAcrPullRoleDefinitionId
    principalType: 'ServicePrincipal'
  }
}

//App GW Role Assignments
resource resAppGwNetContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, parAppgwId, varAppGwNetContributorRoleDefinitionId)
  properties: {
    roleDefinitionId: varAppGwNetContributorRoleDefinitionId
    principalId: reference(parAksClusterId, '2023-08-01', 'Full').properties.addonProfiles.ingressApplicationGateway.identity.objectId
    principalType: 'ServicePrincipal'
  }
}
resource resAppGwContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, parAppgwId, varAppGwContributorRoleDefinitionId)
  properties: {
    roleDefinitionId: varAppGwContributorRoleDefinitionId
    principalId: reference(parAksClusterId, '2023-08-01', 'Full').properties.addonProfiles.ingressApplicationGateway.identity.objectId
    principalType: 'ServicePrincipal'
  }
}

//Metrics Role Assignments
resource resMonitoringReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name:  guid(resourceGroup().id, resMspromMonitorWorkspace.name, varMonitoringReaderRoleDefinitionId)
  scope: resMspromMonitorWorkspace
  properties: {
    roleDefinitionId: varMonitoringReaderRoleDefinitionId
    principalId: resGrafana.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
resource resMonitoringDataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name:  guid(resourceGroup().id, resMspromMonitorWorkspace.id, varMonitoringDataReaderRoleId)
  scope: resMspromMonitorWorkspace
  properties: {
    roleDefinitionId: varMonitoringDataReaderRoleId
    principalId: resGrafana.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
resource resGrafanaAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(parUserId)) {
  name:  guid(resourceGroup().id, parUserId, varGrafanaAdminRoleDefinitionId)
  scope: resGrafana
  properties: {
    roleDefinitionId: varGrafanaAdminRoleDefinitionId
    principalId: parUserId
    principalType: 'User'
  }
}
