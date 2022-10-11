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
    $storageaccountName
)

$subnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vNetName | Get-AzVirtualNetworkSubnetConfig -Name $subnetName
Add-AzStorageAccountNetworkRule -ResourceGroupName $resourceGroupName -Name $storageaccountName -VirtualNetworkResourceId $subnet.Id
