[CmdletBinding()]
param (
    
    [Parameter(Mandatory = $true)]
    [string]
    $resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $location,
    [Parameter(Mandatory = $true)]
    [string]
    $applicationInsightsName
   
)

Write-Host "Creating Shared App Insights Resource for Pirean"

az monitor app-insights component create --app $applicationInsightsName --resource-group $resourceGroupName --location $location --kind "web" --application-type "web"