# Author - Ravi Yadav, MVP
# October 16, 2017
# This script will connect all of your VMs within a given Resource Group to your OMS/Log Analytics workspace
# Lines 6,7,8,9 need to be updated with respect to your environment

Login-AzureRMAccount -SubscriptionName "Your Subscription Name"
Select-AzureRMSubscription -SubscriptionId "Your Subscription ID" 
$workspaceName = "Your OMS/Log Analytics Name"
$resourcegroup = "Your OMS/Log Analytics Resource Group Name"
$workspace = Get-AzureRmOperationalInsightsWorkspace -Name $workspaceName -ResourceGroupName $resourcegroup

if ($workspace.Name -ne $workspaceName)
{
    Write-Error "Unable to find OMS Workspace $workspaceName."
}

$workspaceId = $workspace.CustomerId
$workspaceKey = (Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $workspace.ResourceGroupName -Name $workspace.Name).PrimarySharedKey
#get all vms within the resource group
$vms = Get-AzureRmVM -ResourceGroupName $resourcegroup 

foreach ($vm in $vms)
{
    $location = $vm.Location
    $vm = $vm.Name  
    # For Windows VM uncomment the following line
    Set-AzureRmVMExtension -ResourceGroupName $resourcegroup -VMName $vm -Name 'MicrosoftMonitoringAgent' -Publisher 'Microsoft.EnterpriseCloud.Monitoring' -ExtensionType 'MicrosoftMonitoringAgent' -TypeHandlerVersion '1.0' -Location $location -SettingString "{'workspaceId': '$workspaceId'}" -ProtectedSettingString "{'workspaceKey': '$workspaceKey'}"
}