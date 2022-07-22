
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
$creds = New-Object System.Management.Automation.PSCredential $adminSqlLogin,$secureString
$Password = $creds.GetNetworkCredential().Password

try
{
invoke-sqlcmd -inputfile $sqlscriptpath  -serverinstance $serverName -database $databaseName -UserName "$adminSqlLogin" -Password $Password
}
catch
{

}