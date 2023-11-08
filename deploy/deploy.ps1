az login

$clientName = 'tyler'
$clientInitials = 'tm'

$rgName = 'azure-devops-track-aks-exercise-'+$($clientName)
$rgLocation = 'uksouth'
# $acrName = 'aks'+$($clientInitials)+'acr'

# git clone https://github.com/Azure-Samples/azure-voting-app-redis
# Set-Location azure-voting-app-redis
# docker compose -f docker-compose.yaml up -d
# docker compose down

az group create --name $rgName --location $rgLocation
# az acr create --resource-group $rgName --name $acrName --sku Basic

# az acr build --registry $acrName --image mcr.microsoft.com/oss/bitnami/redis:latest ./azure-vote-back
# az acr build --registry $acrName --image mcr.microsoft.com/azuredocs/azure-vote-front:latest ./azure-vote-front

# az acr repository list --name $acrName.azurecr.io --output table

az deployment group create --resource-group $rgName --template-file .\deploy\main.bicep --parameters parLocation=$rgLocation parInitials=$clientInitials