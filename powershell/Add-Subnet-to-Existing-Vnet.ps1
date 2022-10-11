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
    $subnetName
)
#Get existing Azure Virtual Network information
$azvNet = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $resourceGroupName
Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $AddressPrefix -VirtualNetwork $azvNet 

#Make changes to vNet
$azvNet | Set-AzVirtualNetwork