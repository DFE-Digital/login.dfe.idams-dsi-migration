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
# # Get the resource ID of the App Insight Resource and save it in a variable
# $resourceid= $(az resource show --resource-group $resourceGroupName --name  $applicationInsightsName --resource-type "microsoft.insights/components" --query id --output tsv)


Write-Host "Create Private Link Scope"

az monitor private-link-scope  create --name $scopeName --resource-group $resourceGroupName

# Get the resource ID of the App Insight Resource and save it in a variable

Write-Host "Get Subnet Id"
$subnetId = $(az network vnet subnet show --name "pirean-ampls-sn-1" --vnet-name "s141t01-signin-shd-vnet" --resource-group $resourceGroupName --query 'id' --output tsv)

Write-Host "Subnet Id :" $subnetId
# Get the resource ID of the App Insight Resource and save it in a variable
Write-Host "Get privateConnectionResourceId"
$privateConnectionResourceId= $(az resource show --resource-group $resourceGroupName --name  $scopeName --resource-type "microsoft.insights/privatelinkscopes" --query id --output tsv)
Write-Host "privateConnectionResourceId" $privateConnectionResourceId

Write-Host "Associate Private Link Scope for AppInsight Resource"
$randomString = ([System.Guid]::NewGuid()).ToString()
az network private-endpoint create --name "pirean-appinsight-private-endpoint" --resource-group $resourceGroupName --subnet $subnetId --private-connection-resource-id $privateConnectionResourceId --private-link-service-connection "connection"-$randomString --location $location




# az monitor private-link-scope update --name $scopeName --resource-group $resourceGroupName --private-link-service Connections --associated-resource $resourceid --tags Environment=$environmentName Product="DfE Sign-in" Service Offering="DfE Sign-in"
   
