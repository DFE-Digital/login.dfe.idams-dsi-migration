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

Remove-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName 'd02-testorgs01'
