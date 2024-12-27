param(
    [string] $ResourceGroupName,
    [string] $Location 
)

az group create --name $ResourceGroupName --location $Location

az stack group create -n deploy$(Get-Date -f "yyyyMMddhhmmss") --resource-group $ResourceGroupName --deny-settings-mode none -f .\main.bicep -p .\main.parameters.json