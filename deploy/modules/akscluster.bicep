param parLocation string
param parInitials string
param parTenantId string
param parEntraGroupId string
param parAksClusterAdminUsername string
param parSshPublicKey string
param parAksClusterName string
param parAppgwId string
param parLawId string
param parSystemVnetSubnetId string
param parSystemPodSubnetId string
param parApplicationVnetSubnetId string
param parApplicationPodSubnetId string

//AKS Cluster
resource resAksCluster 'Microsoft.ContainerService/managedClusters@2023-09-01' = {
  name: parAksClusterName
  location: parLocation
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.27.7'
    dnsPrefix: 'aks-${parInitials}-akscluster-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      networkDataplane: 'azure'
    }
    agentPoolProfiles: [
      {
        name: 'system'
        count: 1
        vmSize: 'Standard_B2s'
        maxPods: 30
        maxCount: 10
        minCount: 1
        enableAutoScaling: true
        osType: 'Linux'
        osSKU: 'CBLMariner'
        mode: 'System'
        vnetSubnetID: parSystemVnetSubnetId
        podSubnetID: parSystemPodSubnetId
      }
      {
        name: 'application'
        count: 1
        vmSize: 'Standard_B2s'
        maxPods: 30
        maxCount: 10
        minCount: 1
        enableAutoScaling: true
        osType: 'Linux'
        osSKU: 'CBLMariner'
        mode: 'System'
        vnetSubnetID: parApplicationVnetSubnetId
        podSubnetID: parApplicationPodSubnetId
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
    addonProfiles: {
      ingressApplicationGateway: {
        enabled: true
        config: {
          applicationGatewayId: parAppgwId
        }
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: parLawId
          useAADAuth: 'true'
        }
      }
    }
    azureMonitorProfile: {
      metrics: {
        enabled: true
        kubeStateMetrics: {
          metricAnnotationsAllowList: ''
          metricLabelsAllowlist: ''
        }
      }
    }
    linuxProfile: {
      adminUsername: parAksClusterAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: parSshPublicKey
          }
        ]
      }
    }
  }
}


//Outputs
output outAksClusterName string = resAksCluster.name
output outAksClusterId string = resAksCluster.id
output outAksClusterObjectId string = resAksCluster.properties.identityProfile.kubeletidentity.objectId
