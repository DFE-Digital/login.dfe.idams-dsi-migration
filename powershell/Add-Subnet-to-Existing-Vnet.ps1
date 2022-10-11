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
# $vNetName = "s141d01-signin-shd-vnet"
# $resourceGroupName = "s141d01-shd"
# $AddressPrefix = "10.0.62.0/24"
# $subnetName = "pmshdst-sn"
#Get existing Azure Virtual Network information
$azvNet = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $resourceGroupName
Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $AddressPrefix -VirtualNetwork $azvNet 

#Make changes to vNet
$azvNet | Set-AzVirtualNetwork