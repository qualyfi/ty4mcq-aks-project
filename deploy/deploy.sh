az login

# Enter Details Below

################
clientName="tmcqueen"
clientInitials="tcm"
location="uksouth"

entraGroupName="AKS EID Admin Group"
kvSecretName="ExampleSecret"
kvSecretValue="RaynersLane"

subscription="e5cfa658-369f-4218-b58e-cece3814d3f1"

aksClusterAdminUsername="ty4mcq"

kubectlNamespace="production"
################

az account set --subscription $subscription

tenantId="$(az account show --query tenantId -o tsv)"
entraGroupId="$(az ad group list --display-name "$entraGroupName" --query "[].{id:id}" --output tsv)"

userId=$(az ad signed-in-user show --query id --output tsv)

rgName="azure-devops-track-aks-exercise-$clientName"

acrName="aksacr$clientInitials"

aksClusterName="aks-$clientInitials-akscluster"

sshKeyName="aks-$clientInitials-sshkey"
sshPublicKeyFile="$sshKeyName.pub"

keyVaultName="aks-$clientInitials-kv-$(shuf -i 0-9999999 -n 1)"

secretProviderClassName="aks-$clientInitials-spc"

az config set defaults.group=$rgName

# Create Resouce Group
az group create --name $rgName --location $location

# Create SSH Key + Format for Parameter
ssh-keygen -m PEM -t rsa -b 4096 -f ./$sshKeyName
readKey=$(< $sshPublicKeyFile)
arrayKey=($readKey)
sshPublicKey=${arrayKey[@]:0:2}

# Deploy Bicep Files
az deployment group create --resource-group $rgName --template-file ./deploy/main.bicep --parameters parLocation=$location parInitials=$clientInitials parUserId=$userId parTenantId=$tenantId parEntraGroupId=$entraGroupId parAcrName=$acrName parSshPublicKey="$sshPublicKey" parAksClusterName=$aksClusterName parAksClusterAdminUsername=$aksClusterAdminUsername

# Access AKS Cluster
az aks get-credentials -n $aksClusterName -g $rgName

# Enable CSI Driver
az aks enable-addons --addons azure-keyvault-secrets-provider --name $aksClusterName --resource-group $rgName

# Create Key Vault
az keyvault create -n $keyVaultName -g $rgName -l $location --enable-rbac-authorization

# Assign Key Vault Roles to CSI Driver Managed Identity
export clientId="$(az aks show -g $rgName -n $aksClusterName --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)"
export keyVaultId="$(az keyvault show --name $keyVaultName --resource-group $rgName --query id -o tsv)"

az role assignment create --role "Key Vault Administrator" --assignee $clientId --scope "/$keyVaultId"
az role assignment create --role "Key Vault Secrets User" --assignee $clientId --scope "/$keyVaultId"
az role assignment create --role "Key Vault Administrator" --assignee $userId --scope "/$keyVaultId"
az role assignment create --role "Key Vault Secrets User" --assignee $userId --scope "/$keyVaultId"


# Set Secret
az keyvault secret set --vault-name $keyVaultName -n $kvSecretName --value $kvSecretValue

# ACR Import
az acr import --name $acrName --source mcr.microsoft.com/azuredocs/azure-vote-front:v1 --image azure-vote-front:v1
az acr import --name $acrName --source mcr.microsoft.com/oss/bitnami/redis:6.0.8 --image redis:6.0.8

export yamlSecretProviderClassName=$secretProviderClassName
export yamlClientId=$clientId
export yamlKeyVaultName=$keyVaultName
export yamlTenantId=$tenantId
export yamlKvSecretName=$kvSecretName

# Create Namespace
kubectl create namespace $kubectlNamespace

# Substitute Variables + Apply SPC/Manifest File
envsubst < deploy/yaml/spc.yaml | kubectl apply -f - --namespace $kubectlNamespace
envsubst < deploy/yaml/manifest.yaml | kubectl apply -f - --namespace $kubectlNamespace

# Enable Container Insights
kubectl apply -f deploy/yaml/container-azm-ms-agentconfig.yaml

# Enable HPA
kubectl autoscale deployment azure-vote-front --namespace $kubectlNamespace --cpu-percent=50 --min=1 --max=10
kubectl autoscale deployment azure-vote-back --namespace $kubectlNamespace --cpu-percent=50 --min=1 --max=10

kubectl get pods --namespace $kubectlNamespace
kubectl get hpa --namespace $kubectlNamespace
