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
    $databaseName,
    [Parameter(Mandatory = $true)]
    [string]
    $adminSqlLogin,
    [Parameter(Mandatory = $true)]
    [string]
    $adminpwd,
    [Parameter(Mandatory = $true)]
    [string]
    $sqlscriptpath
     
)


Remove-AzureRmSqlDatabase -ServerName $serverName -ResourceGroupName $resourceGroupName -DatabaseName $databaseName