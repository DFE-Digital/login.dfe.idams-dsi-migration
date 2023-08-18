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
    $applicationInsightsName,
    [Parameter(Mandatory = $true)]
    [string]
    $scopeName
   
)
# Get the resource ID of the App Insight Resource and save it in a variable
$resourceid= $(az resource show --resource-group $resourceGroupName --name  $applicationInsightsName --resource-type "microsoft.insights/components" --query id --output tsv)


Write-Host "Create Private Link Scope"

az network private-link scope create --name $scopeName --resource-group $resourceGroupName

Write-Host "Associate Private Link Scope for AppInsight Resource"

az network private-link scope update --name $scopeName --resource-group $resourceGroupName --private-link-service Connections --associated-resource $resourceid
