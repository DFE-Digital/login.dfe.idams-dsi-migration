[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $subscriptionId,  
    [Parameter(Mandatory = $true)]
    [string]
    $vNetName,    
    [Parameter(Mandatory = $true)]
    [string]
    $resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $functionAppRG,
    [Parameter(Mandatory = $true)]
    [string]
    $AddressPrefix,
    [Parameter(Mandatory = $true)]
    [string]
    $subnetName,
    [Parameter(Mandatory = $true)]
    [string]
    $storageaccountName,
    [Parameter(Mandatory = $true)]
    [string]
    $storageaccountRGName,
    [Parameter(Mandatory = $true)]
    [string]
    $functionAppName,
    [Parameter(Mandatory = $true)]
    [string]
    $subnetNamefa
)


$subnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vNetName | Get-AzVirtualNetworkSubnetConfig -Name $subnetName
$vnetResouceId = "/subscriptions/"+$subscriptionId+"/resourceGroups/"+$resourceGroupName+"/providers/Microsoft.Network/virtualNetworks/"+$vNetName

Write-Host "Integrate Storage Account to the Vnet"

Add-AzStorageAccountNetworkRule -ResourceGroupName $storageaccountRGName -Name $storageaccountName -VirtualNetworkResourceId $subnet.Id
az storage account update --name $storageaccountName --resource-group $storageaccountRGName --default-action Deny
Write-Host "Integrate Function App to the Vnet"

az functionapp  vnet-integration add --resource-group $functionAppRG --name $functionAppName --vnet $vnetResouceId --subnet $subnetName
