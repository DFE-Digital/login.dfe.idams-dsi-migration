[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $vNetName,    
    [Parameter(Mandatory = $true)]
    [string]
    $resourceGroupName,
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
    $storageaccountRGName
)

$subnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vNetName | Get-AzVirtualNetworkSubnetConfig -Name $subnetName
Add-AzStorageAccountNetworkRule -ResourceGroupName $storageaccountRGName -Name $storageaccountName -VirtualNetworkResourceId $subnet.Id
az storage account update --name $storageaccountName --resource-group $storageaccountRGName --default-action Deny
