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


$vNetName = 'global_vnet_eastus'
$resourceGroupName = 'vcloud-lab.com'
$AddressPrefix = @('10.10.0.0/16')
$subnetName = 'prod01-10.10.1.x'


#Get existing Azure Virtual Network information
$azvNet = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $resourceGroupName
Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnet01AddressPrefix -VirtualNetwork $azvNet 

#Make changes to vNet
$azvNet | Set-AzVirtualNetwork