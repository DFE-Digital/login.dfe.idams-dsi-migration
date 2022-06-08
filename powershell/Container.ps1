[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,    
    [Parameter(Mandatory = $true)]
    [string]
    $ContainerName
     
)


az storage container create --name $ContainerName --account-name $StorageAccountName --auth-mode login

