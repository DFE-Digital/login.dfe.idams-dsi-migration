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
Write-Host "Create Topic - providerprofilesync"
az servicebus topic create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --name $serviceBusTopicName

Write-Host "Create Subscriptions for Topic - providerprofilesync"

Write-Host "Create Subscription - ppsyncstatus-messages"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name $serviceBusTopicName --name 'ppsyncstatus-messages'
Write-Host "Create Subscription - ppdeltacollect-messages"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name $serviceBusTopicName --name 'ppdeltacollect-messages'
Write-Host "Create Subscription - ppdeltateachers-messages"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name $serviceBusTopicName --name 'ppdeltateachers-messages'
Write-Host "Create Subscription - ppdeltas2s-messages"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name $serviceBusTopicName --name 'ppdeltas2s-messages'

Write-Host "Create Topic - providerprofilecache"
az servicebus topic create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --name 'providerprofilecache'

Write-Host "Create Subscriptions for Topic - providerprofilecache"
Write-Host "Create Subscriptions - ppcachestatus-messages"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name 'providerprofilecache' --name 'ppcachestatus-messages'
