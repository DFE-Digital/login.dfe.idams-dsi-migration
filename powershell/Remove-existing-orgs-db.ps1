[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $resourceGroupName,    
    [Parameter(Mandatory = $true)]
    [string]
    $serverName,
    [Parameter(Mandatory = $true)]
    [string]
    $databaseName
    
     
)


Remove-AzureRmSqlDatabase -ServerName $serverName -ResourceGroupName $resourceGroupName -DatabaseName 'd02-testorgs01'