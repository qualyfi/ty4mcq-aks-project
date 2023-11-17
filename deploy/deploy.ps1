az login

az account show
az ad group list

$clientName = 'tyler'
$clientInitials = 'tm'

$tenantId = 'd4003661-f87e-4237-9a9b-8b9c31ba2467'
$entraGroupId = 'c049d1ab-87d3-491b-9c93-8bea50fbfbc3'

$rgName = '3azure-devops-track-aks-exercise-'+$($clientName)
$rgLocation = 'uksouth'
$acrName = 'aks'+$($clientInitials)+'acr'

# az config set defaults.group $rgName

# git clone https://github.com/Azure-Samples/azure-voting-app-redis
# docker compose -f azure-voting-app-redis/docker-compose.yaml up -d
# docker images
# docker ps
# docker compose down

az group create --name $rgName --location $rgLocation

# az acr build --registry $acrName --image mcr.microsoft.com/oss/bitnami/redis:6.0.8 ./azure-vote-back:6.0.8
# az acr build --registry $acrName --image mcr.microsoft.com/azuredocs/azure-vote-front:v1 ./azure-vote-front:v1

# az acr repository list --name $acrName.azurecr.io --output table

az deployment group create --resource-group $rgName --template-file .\deploy\main.bicep --parameters parLocation=$rgLocation parInitials=$clientInitials parTenantId=$tenantId parEntraGroupId=$entraGroupId parAcrName=$acrName

az acr login -n akstmacr

docker pull mcr.microsoft.com/azuredocs/azure-vote-front:v1
docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 akstmacr.azurecr.io/azure-vote-front:v1
docker push akstmacr.azurecr.io/azure-vote-front:v1

docker pull mcr.microsoft.com/oss/bitnami/redis:6.0.8
docker tag mcr.microsoft.com/oss/bitnami/redis:6.0.8 akstmacr.azurecr.io/azure-vote-back:6.0.8
docker push akstmacr.azurecr.io/azure-vote-back:6.0.8

az aks get-credentials -g $rgName -n 'aks-tm-akscluster'

kubectl create namespace production
kubectl get naamespace production

kubectl apply -f azure-vote-front/azure-vote-all-in-one-redis.yaml --namespace production
kubectl get service azure-vote-front --watch