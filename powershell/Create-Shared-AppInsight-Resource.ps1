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
az resource create --resource-group $resourceGroupName --name $applicationInsightsName --resource-type "Microsoft.Insights/components" --location $location 
