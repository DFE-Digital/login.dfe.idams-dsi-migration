# [CmdletBinding()]
# param (
    
#     [Parameter(Mandatory = $true)]
#     [string]
#     $resourceGroupName,
#     [Parameter(Mandatory = $true)]
#     [string]
#     $functionAppName

   
# )
                  
# Write-Host "Disable Function FTP-State"
# # $jsonPayload = @{"ftpsState" = "Disabled"} | ConvertTo-Json

# az functionapp config set --resource-group $resourceGroupName --name $functionAppName --ftps-state Disabled


# Replace this value with the specific string you're looking for in the function app name
$targetString = "pirean"

# Get a list of function apps containing the target string
$functionApps = Get-AzWebApp | Where-Object { $_.Name -like "*$targetString*" } | Select-Object -ExpandProperty Name

# Loop through each function app
foreach ($functionApp in $functionApps) {
    $resourceGroup = (Get-AzResource -ResourceId $functionApp.ResourceId).ResourceGroupName
    Write-Host "Processing function app: $functionApp in resource group: $resourceGroup"

    # Update the FTP state of the function app (replace 'AllAllowed' with your actual logic)
    Set-AzWebApp -ResourceGroupName $resourceGroup -Name $functionApp -FtpsState "Disabled"
    
    Write-Host "FTP state updated for function app: $functionApp"
}
