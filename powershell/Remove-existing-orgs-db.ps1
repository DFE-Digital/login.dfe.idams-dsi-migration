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
$availableDatabase = Get-AzResource -ResourceGroupName $resourceGroupName -name 's141d02-signin-shd-sql/s141d02-signin-organisations-db'
if ($availableDatabase){

    Remove-AzResource -ResourceId $availableDatabase.Id -Force
    Write-Host "Remove the sql db $databaseName"

}else{
    Write-Host "The sql db $databaseName does not exist" 

    }

