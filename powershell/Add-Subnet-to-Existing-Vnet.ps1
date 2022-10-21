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
    $AddressPrefixStorage,
    [Parameter(Mandatory = $true)]
    [string]
    $AddressPrefixFunction,
    [Parameter(Mandatory = $true)]
    [string]
    $subnetNameStorage,
    [Parameter(Mandatory = $true)]
    [string]
    $subnetNameFunction
)

#Get existing Azure Virtual Network information
Write-Host "Start"
$azvNet = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $resourceGroupName
$existingsubnetStorage = Get-AzVirtualNetworkSubnetConfig -Name $subnetNameStorage -VirtualNetwork $azvNet -ErrorAction SilentlyContinue
$existingsubnetFunction = Get-AzVirtualNetworkSubnetConfig -Name $subnetNameFunction -VirtualNetwork $azvNet -ErrorAction SilentlyContinue

if (!$existingsubnetStorage) {
    $ServiceEndPoint = New-Object 'System.Collections.Generic.List[String]'
    $ServiceEndPoint.Add("Microsoft.Storage")
    $ServiceEndPoint.Add("Microsoft.Web")
        
    Add-AzVirtualNetworkSubnetConfig -Name $subnetNameStorage -AddressPrefix $AddressPrefixStorage -VirtualNetwork $azvNet -ServiceEndpoint $ServiceEndPoint

    #Make changes to vNet
    $azvNet | Set-AzVirtualNetwork

}

if (!$existingsubnetFunction) {
    #Get existing service endpoints
    $ServiceEndPoint = New-Object 'System.Collections.Generic.List[String]'
    $ServiceEndPoint.Add("Microsoft.Storage")
    $ServiceEndPoint.Add("Microsoft.Web")
        
    Add-AzVirtualNetworkSubnetConfig -Name $subnetNameFunction -AddressPrefix $AddressPrefixFunction -VirtualNetwork $azvNet -ServiceEndpoint $ServiceEndPoint

    #Make changes to vNet
    $azvNet | Set-AzVirtualNetwork

}
