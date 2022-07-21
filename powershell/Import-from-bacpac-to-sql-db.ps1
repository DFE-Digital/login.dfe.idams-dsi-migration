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
[Console]::Write("SQL Login Details:")
[Console]::Write($adminSqlLogin)
[Console]::Write("SQL Password Details:")
[Console]::Write($adminpwd)

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

#Cancel-AzSQLImportExportOperation -resourceGroupName $resourceGroupName -serverName 's141d02-signin-shd-sql' -databaseName 'd02-testorgs01'
$secureString = convertto-securestring $adminpwd -asplaintext -force
# Import bacpac to database with an S3 performance level
$importRequest = New-AzSqlDatabaseImport -ResourceGroupName $resourceGroupName `
    -ServerName 's141d02-signin-shd-sql' `
    -DatabaseName 'd02-testorgs01' `
    -DatabaseMaxSizeBytes 10GB `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey $(Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName).Value[0] `
    -StorageUri "https://$storageaccountname.blob.core.windows.net/$storageContainerName/$bacpacFilename" `
    -Edition "Standard" `
    -ServiceObjectiveName "S3" `
    -AdministratorLogin "$adminSqlLogin" `
    -AdministratorLoginPassword $secureString

# Check import status and wait for the import to complete
$importStatus = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
[Console]::Write("Importing")
while ($importStatus.Status -eq "InProgress")
{
    $importStatus = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
    [Console]::Write(".")
    Start-Sleep -s 10
}
[Console]::WriteLine("")
$importStatus
