[CmdletBinding()]
param (
    
    [Parameter(Mandatory = $true)]
    [string]
    $resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $functionAppName

   
)
                  
Write-Host "Disable Function FTP-State"

az functionapp update --resource-group $resourceGroupName --name $functionAppName --set properties.ftpsState=Disabled
