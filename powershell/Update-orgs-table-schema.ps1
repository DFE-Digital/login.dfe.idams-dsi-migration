
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
Import-Module sqlserver
$secureString = convertto-securestring $adminpwd -asplaintext -force


invoke-sqlcmd -inputfile $sqlscriptpath  -serverinstance $serverName -database $databaseName -UserName $adminpwd -Password $secureString