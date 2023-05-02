[CmdletBinding()]
param (
     
    [Parameter(Mandatory = $true)]
    [string]
    $resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $serviceBusNamespace,
    [Parameter(Mandatory = $true)]
    [string]
    $topicName,
    [Parameter(Mandatory = $true)]
    [string]
    $subscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $subnetNameFunction
)
Write-Host "Create Topic"
az servicebus topic create --resource-group $resourceGroupName --namespace-name $serviceBusNamespace --name $topicName
Write-Host "Create Subscription"
az servicebus topic subscription create --resource-group $resourceGroupName --namespace-name $serviceBusNamespace --topic-name $topicName --name $subscriptionName