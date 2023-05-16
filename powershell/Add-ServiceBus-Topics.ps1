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

Write-Host "Create Subscription - ppcachestatus-messages"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name $serviceBusTopicName --name 'ppcachestatus-messages'
Write-Host "Create Subscription - ppsyncstatus-messages"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name $serviceBusTopicName --name 'ppsyncstatus-messages'
Write-Host "Create Subscription - ppdeltacollect-messages"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name $serviceBusTopicName --name 'ppdeltacollect-messages'
Write-Host "Create Subscription - ppdeltateachers-messages"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name $serviceBusTopicName --name 'ppdeltateachers-messages'
Write-Host "Create Subscription - ppdeltas2s-messages"
az servicebus topic subscription create --resource-group $serviceBusResourceGroupName --namespace-name $serviceBusNamespace --topic-name $serviceBusTopicName --name 'ppdeltas2s-messages'