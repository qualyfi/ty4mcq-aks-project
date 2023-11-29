param parInitials string
param parLocation string

resource resLaw 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'aks-${parInitials}-law'
  location: parLocation
}

//Outputs
output outLawId string = resLaw.id
