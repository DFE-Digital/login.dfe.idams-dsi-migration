[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $vNetName,    
    [Parameter(Mandatory = $true)]
    [string]
    $resourceGroupName,
    [Parameter(Mandatory = $true)]
    [String[]]
    $AddressPrefix,
    [Parameter(Mandatory = $true)]
    [String[]]
    $subnetName
)

#Get existing Azure Virtual Network information
$subnetNameArray = $subnetName.Split(",")
$addressPrefixArray = $AddressPrefix.Split(",")
$azvNet = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $resourceGroupName
For ($i = 0; $i -lt $subnetNameArray.Length; $i++) {
   
    $existingsubnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetNameArray[$i] -VirtualNetwork $azvNet -ErrorAction SilentlyContinue

    if (!$existingsubnet) {
        #Get existing service endpoints
        $ServiceEndPoint = New-Object 'System.Collections.Generic.List[String]'
        $ServiceEndPoint.Add("Microsoft.Storage")
        $ServiceEndPoint.Add("Microsoft.Web")
        
        Add-AzVirtualNetworkSubnetConfig -Name $subnetNameArray[$i] -AddressPrefix $addressPrefixArray[$i] -VirtualNetwork $azvNet -ServiceEndpoint $ServiceEndPoint

        #Make changes to vNet
        $azvNet | Set-AzVirtualNetwork

    }
}