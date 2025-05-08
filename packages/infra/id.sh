githubOrganizationName='jdbenn'
githubRepositoryName='ingestiq'

applicationRegistrationDetails=$(az ad app create --display-name "${githubRepositoryName}-workflow")
applicationRegistrationObjectId=$(echo $applicationRegistrationDetails | jq -r '.id')
applicationRegistrationAppId=$(echo $applicationRegistrationDetails | jq -r '.appId')

az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{\"name\":\"${githubRepositoryName}-workflow\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

   resourceGroupResourceId=$(az group create --name IngestIQ --location centralus --query id --output tsv)

az ad sp create --id $applicationRegistrationObjectId
az role assignment create \
   --assignee $applicationRegistrationAppId \
   --role Contributor \
   --scope $resourceGroupResourceId