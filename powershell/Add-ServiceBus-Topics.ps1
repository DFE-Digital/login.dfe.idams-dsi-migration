[CmdletBinding()]
param (
     
    [Parameter(Mandatory = $true)]
    [string]
    $serviceBusResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $serviceBusNamespace,
    [Parameter(Mandatory = $true)]
    [string]
    $serviceBusTopicName,
    [Parameter(Mandatory = $true)]
    [string]
    $serviceBusSubscriptionName
    
)
Write-Host "Create Topic"
az servicebus topic create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --name $serviceBusTopicName
Write-Host "Create Subscription"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name $serviceBusTopicName --name $serviceBusSubscriptionName