[CmdletBinding()]
param (
     
    [Parameter(Mandatory = $true)]
    [string]
    $serviceBusResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $serviceBusNamespace,
    [Parameter(Mandatory = $true)]
    [string]
    $subnetName,
    [Parameter(Mandatory = $true)]
    [string]
    $vnetName
    
)
Write-Host "Create Network Rule to allow connections from Delta Functions"
az servicebus namespace network-rule add --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --subnet $subnetName --vnet-name $vnetName
