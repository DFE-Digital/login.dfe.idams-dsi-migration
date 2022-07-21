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
    $storageAccountName,
    [Parameter(Mandatory = $true)]
    [string]
    $storageContainerName,
    [Parameter(Mandatory = $true)]
    [string]
    $bacpacFilename,
    [Parameter(Mandatory = $true)]
    [string]
    $adminSqlLogin,
    [Parameter(Mandatory = $true)]
    [string]
    $adminpwd
     
)
function Cancel-AzSQLImportExportOperation
{
    param
    (
        [parameter(Mandatory=$true)][string]$resourceGroupName
        ,[parameter(Mandatory=$true)][string]$serverName
        ,[parameter(Mandatory=$true)][string]$databaseName
    )

    $Operation = Get-AzSqlDatabaseActivity -ResourceGroupName $ResourceGroupName -ServerName $ServerName -DatabaseName $DatabaseName | Where-Object {($_.Operation -like "Export*" -or $_.Operation -like "Import*") -and $_.State -eq "InProgress"}
    
    if(-not [string]::IsNullOrEmpty($Operation))
    {
        do
        {
            Write-Host -ForegroundColor Cyan ("Operation " + $Operation.Operation + " with OperationID: " + $Operation.OperationId + " is now " + $Operation.State)
            $UserInput = Read-Host -Prompt "Should I cancel this operation? (Y/N)"
        } while($UserInput -ne "Y" -and $UserInput -ne "N")

        if($UserInput -eq "Y")
        { 
            "Canceling operation"
            Stop-AzSqlDatabaseActivity -ResourceGroupName $ResourceGroupName -ServerName $ServerName -DatabaseName $DatabaseName -OperationId $Operation.OperationId
        }
        else 
        {"Exiting without canceling the operation"}
        
    }
    else
    {
        "No import or export operation is now running"
    }
}

Cancel-AzSQLImportExportOperation

