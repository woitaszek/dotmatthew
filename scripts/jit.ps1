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
# $endTimeUts = Get-Date (Get-Date -AsUTC).AddHours(3) -Format O
$endTimeUtc = (Get-Date).AddHours(3).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Deduplicate source addresses, printing any that were duplicates
$sourceAddresses | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object {
    Write-Output "Duplicate source address: $($_.Name)"
}
$sourceAddresses = $sourceAddresses | Sort-Object -Unique

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
Write-Output "  SourceAddresses: $sourceAddresses"
foreach ($sourceAddress in $sourceAddresses) {
    Write-Output "  * $sourceAddress"
}
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

# Note that allowedSourceAddressPrefix seems like it could expect an array
# from the samples but in practice it doesn't work that way.
#
# Microsoft.Azure.Commands.Security.Models.JitNetworkAccessPolicies.PSSecurityJitNetworkAccessPolicyInitiatePort
# The settable properties are:
#   [AllowedSourceAddressPrefix <System.String>],
#   [EndTimeUtc <System.DateTime>],
#   [Number <System.Int32>].
#
# * allowedSourceAddressPrefix = @("x.x.x.x","x.x.x.x")
#   Fails with:  provided must be a valid IPv4 Address Prefix.
# * allowedSourceAddressPrefix = @("x.x.x.x/32","x.x.x.x/32")
#   Doesn't fail but does nothing.
#
# So, we'll make a JIT request for each sourceAddress.

foreach ($sourceAddress in $sourceAddresses) {
    Write-Output "Activating JIT access for SourceAddress: $sourceAddress"

    $jitRequest = (@{
        id = $vm.Id
        ports = @(
            @{
                number = 22
                endTimeUtc = $endTimeUtc
                allowedSourceAddressPrefix = $sourceAddress
            },
            @{
                number = 3389
                allowedSourceAddressPrefix = $sourceAddress
                endTimeUtc = $endTimeUtc
            },
            @{
                number = 60000
                allowedSourceAddressPrefix = $sourceAddress
                endTimeUtc = $endTimeUtc
            },
            @{
                number = 60001
                allowedSourceAddressPrefix = $sourceAddress
                endTimeUtc = $endTimeUtc
            },
            @{
                number = 60002
                allowedSourceAddressPrefix = $sourceAddress
                endTimeUtc = $endTimeUtc
            }
        )
    })

    $jitRequestArr = @($jitRequest)
    Start-AzJitNetworkAccessPolicy -ResourceGroupName $resourceGroupName -Location $vm.Location -Name "default" -VirtualMachine $jitRequestArr

}

Write-Output "JIT access activated for VM: $vmName in Resource Group: $resourceGroupName"
