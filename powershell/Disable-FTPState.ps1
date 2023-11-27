# az functionapp config set --resource-group $resourceGroupName --name $functionAppName --ftps-state Disabled
$targetString = "pirean"

# Get a list of function apps containing the target string
$functionApps = Get-AzWebApp | Where-Object { $_.Name -like "*$targetString*" } | Select-Object -Property Name, ResourceGroup

# Loop through each function app
foreach ($functionApp in $functionApps) {
    $resourceGroup = $functionApp.ResourceGroup
    $functionAppName = $functionApp.Name

    Write-Host "Processing function app: $functionAppName in resource group: $resourceGroup"

    # Update the FTP state of the function app (replace 'AllAllowed' with your actual logic)
    Set-AzWebApp -ResourceGroupName $resourceGroup -Name $functionAppName -FtpsState "Disabled"
    
    Write-Host "FTP state updated for function app: $functionAppName"
}
