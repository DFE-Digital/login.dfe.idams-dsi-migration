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

# az functionapp update --resource-group $resourceGroupName --name $functionAppName --set properties.ftpsState=Disabled
az functionapp config appsettings set --name $functionAppName --resource-group $resourceGroupName --settings WEBSITE_WEBFTP_ENABLED=0

