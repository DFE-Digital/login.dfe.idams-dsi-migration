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
$availableDatabase = Get-AzResource -ResourceGroupName 's141d02-shd' -name 's141d02-signin-shd-sql/d02-testorgs02'
if ($availableDatabase){

    Remove-AzResource -ResourceId $availableDatabase.Id -Force
    Write-Host "Remove the sql db d02-testorgs01" 

}else{
    Write-Host "The sql db d02-testorgs01 does not exist" 

    }

