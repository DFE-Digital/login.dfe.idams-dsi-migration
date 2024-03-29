[CmdletBinding()]
param (
    
    [Parameter(Mandatory = $true)]
    [string]
    $appInsightsResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $appInsightsName,
    [Parameter(Mandatory = $true)]
    [string]
    $functionAppResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $functionAppName
   
)

# $appInsightsKey=$(az monitor app-insights component show --resource-group $appInsightsResourceGroupName --name $appInsightsName --query 'instrumentationKey' -o tsv)
$appInsightsKey = $(az resource show -g $appInsightsResourceGroupName -n $appInsightsName --resource-type "microsoft.insights/components" --query properties.InstrumentationKey)
                  
Write-Host "Associate Shared App Insight with the Import Function"

az functionapp config appsettings set --name $functionAppName --resource-group $functionAppResourceGroupName --settings "APPINSIGHTS_INSTRUMENTATIONKEY=$appInsightsKey"
