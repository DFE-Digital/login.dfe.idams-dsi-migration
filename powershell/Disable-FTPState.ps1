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
$jsonPayload = @{
    ftpsState = "Disabled"
} | ConvertTo-Json
az functionapp config set --resource-group $resourceGroupName --name $functionAppName --generic-configurations $jsonPayload
az functionapp config set --resource-group $resourceGroupName --name $functionAppName --generic-configurations {ftpsState:Disabled}

