az login

az account show
az ad group list

$clientName = 'tyler'
$clientInitials = 'tm'

$tenantId = 'd4003661-f87e-4237-9a9b-8b9c31ba2467'
$entraGroupId = 'c049d1ab-87d3-491b-9c93-8bea50fbfbc3'

$rgName = '8azure-devops-track-aks-exercise-'+$($clientName)
$rgLocation = 'uksouth'
$acrName = 'aks'+$($clientInitials)+'acr'

# az config set defaults.group $rgName

git clone https://github.com/Azure-Samples/azure-voting-app-redis
docker compose -f azure-voting-app-redis/docker-compose.yaml up -d
docker images
docker ps
docker compose down

az group create --name $rgName --location $rgLocation


az deployment group create --resource-group $rgName --template-file .\deploy\main.bicep --parameters parLocation=$rgLocation parInitials=$clientInitials parTenantId=$tenantId parEntraGroupId=$entraGroupId parAcrName=$acrName

az acr build --registry $acrName -g $rgName --image mcr.microsoft.com/azuredocs/azure-vote-front:v1 ./azure-voting-app-redis/azure-vote
az acr build --registry $acrName -g $rgName --image mcr.microsoft.com/oss/bitnami/redis:6.0.8 ./azure-voting-app-redis/azure-vote

az acr repository list -n $acrName --output table

az aks get-credentials -g $rgName -n 'aks-tm-akscluster'

kubectl create namespace production

kubectl apply -f azure-voting-app-redis/azure-vote-all-in-one-redis.yaml --namespace production
kubectl get service azure-vote-front --namespace production --watch