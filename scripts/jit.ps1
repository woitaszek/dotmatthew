# jit.ps1

#
# PowerShell script to enable and activate Just-In-Time (JIT) access for a VM in Azure
#
# Usage:
#
#   .\jit.ps1 -resourceGroupName <ResourceGroupName> -vmName <VMName>
#
# Before running this script, make sure to login to Azure using the following command:
#
#   Connect-AzAccount [-Tenant <TenantId>]
#

#
# Made with help from GitHub Copilot and references:
# https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage
#


#
# Get variables from command line
#

param (
    [string]$resourceGroupName,
    [string]$vmName,
    [string[]]$sourceAddresses
)

# Check if parameters are provided
if (-not $resourceGroupName -or -not $vmName -or -not $sourceAddresses) {
    Write-Error "Usage: .\jit.ps1 -resourceGroupName <ResourceGroupName> -vmName <VMName> -sourceAddresses <SourceAddresses>"
    exit 1
}

# Calculate end time for JIT access
$endTimeUtc = (Get-Date).AddHours(3).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")


#
# Configure a JIT policy for the VM
#

# Get the VM
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

Write-Output "Configuring JIT access for VM:"
Write-Output "  ResourceGroupName: $resourceGroupName"
Write-Output "  ID: $($vm.Id)"
Write-Output "  Name: $($vm.Name)"
Write-Output "  Location: $($vm.Location)"
Write-Output "  SourceAddresses: $($sourceAddresses)"
Write-Output "  EndTimeUtc: $endTimeUtc"

# Define JIT policy
$jitPolicy = (@{
    id = $vm.Id
    ports = @(
        @{
            number = 22
            protocol = "TCP"
            allowedSourceAddressPrefix = @("*")
            maxRequestAccessDuration = "PT3H"
        },
        @{
            number = 3389
            protocol = "TCP"
            allowedSourceAddressPrefix = @("*")
            maxRequestAccessDuration = "PT3H"
        },
        @{
            number = 60000
            protocol = "UDP"
            allowedSourceAddressPrefix = @("*")
            maxRequestAccessDuration = "PT3H"
        },
        @{
            number = 60001
            protocol = "UDP"
            allowedSourceAddressPrefix = @("*")
            maxRequestAccessDuration = "PT3H"
        },
        @{
            number = 60002
            protocol = "UDP"
            allowedSourceAddressPrefix = @("*")
            maxRequestAccessDuration = "PT3H"
        }
    )
})
$jitPolicyArr=@($jitPolicy)

# Set the JIT policy
Set-AzJitNetworkAccessPolicy -Kind "Basic" -Location $vm.Location -Name "default" -ResourceGroupName $resourceGroupName -VirtualMachine $jitPolicyArr
Write-Output "JIT access configured for VM: $vmName in Resource Group: $resourceGroupName"


#
# Activate JIT access for the VM
#

# Define JIT request
$jitRequest = (@{
    id = $vm.Id
    ports = @(
        @{
            number = 22
            allowedSourceAddressPrefix = $sourceAddresses
            endTimeUtc = $endTimeUtc
        },
        @{
            number = 3389
            allowedSourceAddressPrefix = $sourceAddresses
            endTimeUtc = $endTimeUtc
        },
        @{
            number = 60000
            allowedSourceAddressPrefix = $sourceAddresses
            endTimeUtc = $endTimeUtc
        },
        @{
            number = 60001
            allowedSourceAddressPrefix = $sourceAddresses
            endTimeUtc = $endTimeUtc
        },
        @{
            number = 60002
            allowedSourceAddressPrefix = $sourceAddresses
            endTimeUtc = $endTimeUtc
        }
    )
})
$jitRequestArr = @($jitRequest)

# Start the JIT access
Start-AzJitNetworkAccessPolicy -ResourceGroupName $resourceGroupName -Location $vm.Location -Name "default" -VirtualMachine $jitRequestArr
Write-Output "JIT access activated for VM: $vmName in Resource Group: $resourceGroupName"
