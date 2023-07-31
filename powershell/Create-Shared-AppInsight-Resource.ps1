[CmdletBinding()]
param (
    
    [Parameter(Mandatory = $true)]
    [string]
    $resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $location,
    [Parameter(Mandatory = $true)]
    [string]
    $applicationInsightsName
   
)


New-AzResource -ResourceName $applicationInsightsName `
  -ResourceGroupName $resourceGroupName `
  -ResourceType "Microsoft.Insights/components" `
  -Location $location `
  -Properties @{
    "Application_Type" = "web"
  }
