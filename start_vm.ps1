<#
.SYNOPSIS
This is a script to either turn an Azure VM on or off.  If on, it will connect via RDP (assuming you have a saved RDP profile).  Make your details variables instead of parameters when using for yourself.

.DESCRIPTION
This will not do anything if it's already stopped and you say Y to the $stop parameter; if you do not say Y, it will connect you even if it's already started.

.PARAMETER subId
This is your Azure subscription ID

.PARAMETER rgName
This is the name of the Azure Resource Group containing your virtual machine

.PARAMETER vmName
This is the name of your Azure Virtual Machine

.PARAMETER pathToRdp
This is the absolute path to the saved RDP profile for your virtual machine

.PARAMETER stopStr
When Y, you are indicating that you want the VM stopped even it's already stopped.  Anything else indicates that you want your VM on AND you want to connect to it.

#>

Param (
	[String] $subId = $(Read-Host -Prompt "Enter your Azure subscription ID:"),
	[String] $rgName = $(Read-Host -Prompt "Enter your Azure resource group name:"),
	[String] $vmName = $(Read-Host -Prompt "Enter your virtual machine name:"),
	[String] $pathToRdp = $(Read-Host -Prompt "Enter the absolute path to your RDP file: ")
    [String] $stopStr = $(Read-Host -Prompt "Enter 'Y' if you would like to stop the VM rather than start it:")
)

function GetPowerStatus ($vm) {
    ($vm | Select-Object -ExpandProperty Statuses | Select-Object -Last 1 | Select-Object -Property DisplayStatus)
}

$stop = $stopStr -eq 'Y' -or $stopStr -eq 'y'
#Add-AzureAccount
Select-AzureRmSubscription -SubscriptionId $subId
$VM = Get-AzureRmVm -Status -ResourceGroupName $rgName -Name $vmname
$status = GetPowerStatus($VM)
Write-Output("VM current status: $status")

if ($status -like "*Running*" -and $stop -eq $true) {
    Stop-AzureRmVM -Name $vmName -ResourceGroupName $rgName -Force
}
elseif ($status -like "*VM deallocated*") { # if vm is currently stopped
    $job = Start-AzureRmVm -Name $vmName -ResourceGroupName $rgName -AsJob
    $counter = 0
	while ((Get-Job $job.Name).state -eq 'Running')
	{
		 Write-Progress -Activity "Starting VM..."  -PercentComplete $counter -CurrentOperation "" -Status "Please wait."
		 Start-Sleep 15
		 $counter=$counter+1
	}
	Get-Job | Wait-Job
	Get-Job | Remove-Job
}
if($stop -eq $false) {
	$status = GetPowerStatus($VM)
	if($status -like "*Running*") {
		Write-Output("Connecting to VM...")
		ii $pathToRdp
	}
}