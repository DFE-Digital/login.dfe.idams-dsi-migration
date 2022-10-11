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
try {
    $existingsubnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $azvNet

if(!$existingsubnet)
{
    #Get existing service endpoints
    $ServiceEndPoint = New-Object 'System.Collections.Generic.List[String]'
    $ServiceEndPoint.Add("Microsoft.KeyVault")
    #$azvNet.ServiceEndpoints | ForEach-Object { $ServiceEndPoint.Add($_.service) }

    Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $AddressPrefix -VirtualNetwork $azvNet -ServiceEndpoint $ServiceEndPoint

    #Make changes to vNet
    $azvNet | Set-AzVirtualNetwork
}
}
catch {
    Write-Host "An error occurred"
}