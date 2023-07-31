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

az resource create \" --resource-group $resourceGroupName \--resource-type "Microsoft.Insights/components" \--name $applicationInsightsName \--location location \--properties '{"Application_Type":"web"}'"

