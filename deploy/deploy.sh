az login

clientName="tmcqueen"
clientInitials="tm"

tenantId="d4003661-f87e-4237-9a9b-8b9c31ba2467"
entraGroupId="c049d1ab-87d3-491b-9c93-8bea50fbfbc3"
userId=$(az ad signed-in-user show --query id --output tsv)

rgName="azure-devops-track-aks-exercise-$clientName"
location="uksouth"

acrName="aksacr$clientInitials"

aksClusterName="aks-$clientInitials-akscluster"

sshKeyName="aks-$clientInitials-sshkey"
sshPublicKeyFile="$sshKeyName.pub"

keyVaultName="aks-$clientInitials-kv-$(shuf -i 0-9999999 -n 1)"
kvSecretName="ExampleSecret"
kvSecretValue="RaynersLane"

secretProviderClassName="aks-$clientInitials-spc"

git clone https://github.com/Azure-Samples/azure-voting-app-redis
docker compose -f azure-voting-app-redis/docker-compose.yaml up -d
docker images
docker ps
docker compose down

az config set defaults.group=$rgName

az group create --name $rgName --location $location

ssh-keygen -m PEM -t rsa -b 4096 -f ./$sshKeyName
readKey=$(< $sshPublicKeyFile)
arrayKey=($readKey)
sshPublicKey=${arrayKey[@]:0:2}

az deployment group create --resource-group $rgName --template-file ./deploy/main.bicep --parameters parLocation=$location parInitials=$clientInitials parTenantId=$tenantId parEntraGroupId=$entraGroupId parAcrName=$acrName parUserId=$userId parSshPublicKey="$sshPublicKey" parAksClusterName=$aksClusterName

az acr build --registry $acrName -g $rgName --image mcr.microsoft.com/azuredocs/azure-vote-front:v1 ./azure-voting-app-redis/azure-vote
az acr build --registry $acrName -g $rgName --image mcr.microsoft.com/oss/bitnami/redis:6.0.8 ./azure-voting-app-redis/azure-vote

az aks get-credentials -n $aksClusterName -g $rgName

kubectlNamespace="production"
kubectl create namespace $kubectlNamespace

az aks enable-addons --addons azure-keyvault-secrets-provider --name $aksClusterName --resource-group $rgName

az keyvault create -n $keyVaultName -g $rgName -l $location --enable-rbac-authorization
az keyvault secret set --vault-name $keyVaultName -n $kvSecretName --value $kvSecretValue

export clientId="$(az aks show -g $rgName -n $aksClusterName --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)"
export keyVaultId=$(az keyvault show --name $keyVaultName --resource-group $rgName --query id -o tsv)

az role assignment create --role "Key Vault Administrator" --assignee $clientId --scope "/$keyVaultId"

export secretProviderClassName=$secretProviderClassName
export clientId=$clientId
export keyVaultName=$keyvaultName
export tenantId=$tenantId
export kvSecretName=$kvSecretName

envsubst < deploy/manifest.yaml | kubectl apply -f - --namespace $kubectlNamespace

# kubectl apply -f deploy/container-azm-ms-agentconfig.yaml
# kubectl autoscale deployment azure-vote-front --namespace $kubectlNamespace --cpu-percent=50 --min=1 --max=10
# kubectl autoscale deployment azure-vote-back --namespace $kubectlNamespace --cpu-percent=50 --min=1 --max=10

# kubectl get pods --namespace $kubectlNamespace

# kubectl exec busybox-secrets-store-inline-user-msi --namespace $kubectlNamespace -- cat mnt/secrets-store/ExampleSecret

