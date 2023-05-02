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
az servicebus topic create --resource-group $resourceGroupName --namespace-name $serviceBusNamespace --name $topicName
Write-Host "Create Subscription"
az servicebus topic subscription create --resource-group $resourceGroupName --namespace-name $serviceBusNamespace --topic-name $topicName --name $subscriptionName