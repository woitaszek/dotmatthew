#
# Matthew's global PowerShell profile
#
# Parallel to bashrc/global.sh - this file is dot-sourced from $PROFILE
# and contains shared configuration across all Windows machines.
#

$matthewDir = "$HOME\.matthew\powershell"

#
# Oh My Posh prompt
#
$ompTheme = "$matthewDir\themes\mytheme-azure.omp.json"
if (Test-Path $ompTheme) {
    oh-my-posh init pwsh --config $ompTheme | Invoke-Expression
} else {
    Write-Host "WARNING: Oh My Posh theme not found at $ompTheme" -ForegroundColor Yellow
}

#
# Aliases
#
Set-Alias -Name which -Value Get-Command

function gitlog { git log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short @args }
function gitgraph { git log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short --graph @args }

#
# Add powershell/scripts to PATH
#
$psScripts = "$matthewDir\scripts"
if (($env:Path -split ';') -notcontains $psScripts) {
    $env:Path += ";$psScripts"
}

#
# Local per-machine overrides
# Create powershell/profile/local_MACHINENAME.ps1 for machine-specific config
#
$localProfile = "$matthewDir\profile\local_$($env:COMPUTERNAME.ToLower()).ps1"
if (Test-Path $localProfile) {
    . $localProfile
}
