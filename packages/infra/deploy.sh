templateFile="main.bicep"
today=$(date +%Y-%m-%d)
deploymentName="ingest-$today"

az deployment sub create \
    --name $deploymentName \
    --template-file $templateFile \