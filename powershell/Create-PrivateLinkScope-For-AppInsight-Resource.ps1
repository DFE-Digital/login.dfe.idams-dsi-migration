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
    $scopeName,
    [Parameter(Mandatory = $true)]
    [string]
    $environmentName
   
)
# Get the resource ID of the App Insight Resource and save it in a variable
$resourceid= $(az resource show --resource-group $resourceGroupName --name  $applicationInsightsName --resource-type "microsoft.insights/components" --query id --output tsv)


Write-Host "Create Private Link Scope"

az monitor private-link-scope  create --name $scopeName --resource-group $resourceGroupName

Write-Host "Associate Private Link Scope for AppInsight Resource"

az monitor private-link-scope update --name $scopeName --resource-group $resourceGroupName --private-link-service Connections --associated-resource $resourceid --tags Environment=$environmentName Product="DfE Sign-in" Service Offering="DfE Sign-in"
   
