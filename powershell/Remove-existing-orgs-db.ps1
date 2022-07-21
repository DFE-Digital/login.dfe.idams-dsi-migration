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
$availableDatabase = Get-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName 'd02-testorgs01' -ErrorAction SilentlyContinue
if ($availableDatabase){

    Remove-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName 'd02-testorgs01'
    Write-Host "Remove the sql db d02-testorgs01" 

}else{
    Write-Host "The sql db d02-testorgs01 does not exist" 

    }

