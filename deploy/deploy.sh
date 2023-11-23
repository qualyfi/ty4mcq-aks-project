az login

az account show
az ad group list

clientName="mcquetylecm"
clientInitials="qtmc"

tenantId="d4003661-f87e-4237-9a9b-8b9c31ba2467"
entraGroupId="c049d1ab-87d3-491b-9c93-8bea50fbfbc3"

rgName="azure-devops-track-aks-exercise-$clientName"
rgLocation="uksouth"
acrName="aksacr$clientInitials"
aksClusterName="aks-$clientInitials-akscluster"
sshKeyName="aks-$clientInitials-sshkey"
sshPublicKeyFile="$sshKeyName.pub"
userId=$(az ad signed-in-user show --query id --output tsv)
# az config set defaults.group $rgName

git clone https://github.com/Azure-Samples/azure-voting-app-redis
docker compose -f azure-voting-app-redis/docker-compose.yaml up -d
docker images
docker ps
docker compose down

az group create --name $rgName --location $rgLocation

# $sshPublicKey = ConvertTo-SecureString (Get-Content $sshPublicKeyFile) -AsPlainText -Force
# $sshPublicKey = 'ssh-rsa '+(Get-Content $sshPublicKeyFile | ForEach-Object { (($_ -split ' ')[1]).Trim() })
# $vmAdminUsername = ConvertTo-SecureString -String $randUser -AsPlainText -Force

# $readKey = Get-Content -Raw $sshPublicKeyFile
# $arrayKey = $readKey -split " "
# $sshPublicKey = $arrayKey[0..1]

# az sshkey create --name $sshKeyName --resource-group $rgName --public-key $sshPublicKeyFile

ssh-keygen -m PEM -t rsa -b 4096 -f ./$sshKeyName
readKey=$(< $sshPublicKeyFile)
arrayKey=($readKey)
sshPublicKey=${arrayKey[@]:0:2}

az deployment group create --resource-group $rgName --template-file ./deploy/main.bicep --parameters parLocation=$rgLocation parInitials=$clientInitials parTenantId=$tenantId parEntraGroupId=$entraGroupId parAcrName=$acrName parUserId=$userId parSshPublicKey="$sshPublicKey"

az acr build --registry $acrName -g $rgName --image mcr.microsoft.com/azuredocs/azure-vote-front:v1 ./azure-voting-app-redis/azure-vote
az acr build --registry $acrName -g $rgName --image mcr.microsoft.com/oss/bitnami/redis:6.0.8 ./azure-voting-app-redis/azure-vote

az acr repository list -n $acrName --output table

az aks get-credentials -n $aksClusterName -g $rgName

kubectl create namespace production

kubectl apply -f azure-voting-app-redis/azure-vote-all-in-one-redis.yaml --namespace production

kubectl apply -f deploy/container-azm-ms-agentconfig.yaml
kubectl autoscale deployment azure-vote-front --namespace production --cpu-percent=50 --min=1 --max=10
kubectl autoscale deployment azure-vote-back --namespace production --cpu-percent=50 --min=1 --max=10

kubectl apply -f deploy/ingress-azure-vote-front.yaml --namespace production

clientId=$(az aks show -g $rgName -n $aksClusterName --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)
secretProviderClassName="aks-$clientInitials-spc"
keyVaultName="aks-$clientInitials-kv"

cat <<EOF | kubectl apply -f -
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: $secretProviderClassName
  namespace: production
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: $clientId
    keyvaultName: $keyVaultName
    objects: |
      array:
        - |
          objectName: "ExampleSecret"
          objectType: secret
    tenantId: $tenantId
EOF


cat << EOF | envsubst | kubectl apply -f -
kind: Pod
apiVersion: v1
metadata:
  name: busybox-secrets-store-inline-system-msi
spec:
  containers:
    - name: busybox
      image: k8s.gcr.io/e2e-test-images/busybox:1.29-1
      command:
        - "/bin/sleep"
        - "10000"
      volumeMounts:
      - name: secrets-store01
        mountPath: "/mnt/secrets-store"
        readOnly: true
  volumes:
    - name: secrets-store01
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: $secretProviderClassName
EOF

kubectl exec busybox-secrets-store-inline-system-msi -- ls /mnt/secrets-store/
kubectl exec busybox-secrets-store-inline-user-msi -- cat /mnt/secrets-store/ExampleSecret
kubectl get service azure-vote-front --namespace production --watch
