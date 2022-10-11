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
$existingsubnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $azvNet -ErrorAction SilentlyContinue

if(!$existingsubnet)
{
    #Get existing service endpoints
    $ServiceEndPoint = New-Object 'System.Collections.Generic.List[String]'
    $ServiceEndPoint.Add("Microsoft.KeyVault")
    #$azvNet.ServiceEndpoints | ForEach-Object { $ServiceEndPoint.Add($_.service) }

    Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $AddressPrefix -VirtualNetwork $azvNet

    #Make changes to vNet
    $azvNet | Set-AzVirtualNetwork

}
