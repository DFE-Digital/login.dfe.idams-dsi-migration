[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $applicationResourceGroupName,    
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]
    $idamsdsifileshare,
    [Parameter(Mandatory = $true)]
    [string]
    $logicappname,
    [Parameter(Mandatory = $true)]
    [string]
    $PipelineWorkspace,
    [Parameter(Mandatory = $true)]
    [string]
    $artifactName
)

$accountKey = (Get-AzStorageAccountKey -ResourceGroupName $applicationResourceGroupName -Name $StorageAccountName)[0].Value
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $accountKey
$s = Get-AzStorageShare $idamsdsifileshare -Context $ctx

   
if (!$s.ShareClient.GetRootDirectoryClient().GetFileClient("workflow.json").Exists()) {
    Write-Host -ForegroundColor Green "Creating directory in file share.." 
    Get-AzStorageShare -Context $ctx -Name $idamsdsifileshare | New-AzStorageDirectory -Path "/site/wwwroot/$logicappname"  
}
Set-Location "$PipelineWorkspace/$artifactName/"
$CurrentFolder = (Get-Item .).FullName
$files = Get-ChildItem -Recurse | Where-Object { $_.GetType().Name -eq "FileInfo" }

foreach ($file in $files) {
    $path = $file.FullName.Substring($Currentfolder.Length + 1).Replace("\", "/")
    $path = "scripts/" + $path 
              
    try {
        if ($file.FullName.Contains("workflow")) {
            Write-output "Writing: $($file.FullName)" 
            Set-AzStorageFileContent -Share $s.CloudFileShare -Source $file.FullName -Path "/site/wwwroot/$logicappname" -Force
        }
        if ($file.FullName.Contains("connections") -Or $file.FullName.Contains("parameters")) {
            Write-output "Writing: $($file.FullName)" 
            Set-AzStorageFileContent -Share $s.CloudFileShare -Source $file.FullName -Path "/site/wwwroot/" -Force
        }

    }
    catch {
        $message = $_
        Write-Warning "That didn't work: $message"
    }
}