[CmdletBinding()]
param (
     
    [Parameter(Mandatory = $true)]
    [string]
    $serviceBusResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $serviceBusNamespace,
    [Parameter(Mandatory = $true)]
    [string]
    $subnetFunctionName,
    [Parameter(Mandatory = $true)]
    [string]
    $subnetStorageName,
    [Parameter(Mandatory = $true)]
    [string]
    $vnetName
    
)
Write-Host "Create Network Rule to allow connections from Delta Functions"
az servicebus namespace network-rule add --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --subnet $subnetFunctionName --vnet-name $vnetName

Write-Host "Create Network Rule to allow connections from Delta Storage Accounts"
az servicebus namespace network-rule add --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --subnet $subnetStorageName --vnet-name $vnetName
