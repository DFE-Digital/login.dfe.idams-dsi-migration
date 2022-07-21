
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
$secureString = convertto-securestring $adminpwd -asplaintext -force


invoke-sqlcmd -inputfile $sqlscriptpath  -serverinstance 's141d02-signin-shd-sql' -database 'd02-testorgs01' -UserName "$adminSqlLogin" -Password $secureString