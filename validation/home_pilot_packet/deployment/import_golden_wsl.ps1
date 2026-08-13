[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ArchivePath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9a-fA-F]{64}$')]
    [string]$ExpectedSha256,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9._-]+$')]
    [string]$NewDistributionName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$InstallLocation,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^/home/ajm/.+')]
    [string]$PacketPathInDistribution,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^/home/ajm/.+')]
    [string]$DeploymentBundlePathInDistribution,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^/home/ajm/.+')]
    [string]$RuntimeEnvironmentFileInDistribution,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^/home/ajm/.+')]
    [string]$QualificationOutputPathInDistribution,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SignoffName
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Stop-Safely {
    param([string]$Message)
    throw $Message
}

function ConvertTo-BashLiteral {
    param([string]$Value)
    $apostropheEscape = "'" + '"' + "'" + '"' + "'"
    return "'" + $Value.Replace("'", $apostropheEscape) + "'"
}

$wsl = Get-Command wsl.exe -ErrorAction Stop
$archive = (Get-Item -LiteralPath $ArchivePath).FullName
$observedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archive).Hash.ToLowerInvariant()
$expectedHash = $ExpectedSha256.ToLowerInvariant()
if ($observedHash -ne $expectedHash) {
    Stop-Safely "Archive SHA-256 mismatch. Expected $expectedHash; observed $observedHash. No import attempted."
}

Write-Host 'Installed WSL distributions:'
& $wsl.Source --list --verbose
if ($LASTEXITCODE -ne 0) {
    Stop-Safely 'wsl --list --verbose failed. No import attempted.'
}
$installed = @(
    & $wsl.Source --list --quiet |
        ForEach-Object { ($_ -replace "`0", '').Trim() } |
        Where-Object { $_ }
)
if ($LASTEXITCODE -ne 0) {
    Stop-Safely 'wsl --list --quiet failed. No import attempted.'
}
if ($NewDistributionName -in $installed) {
    Stop-Safely "Distribution '$NewDistributionName' already exists. It will not be replaced."
}

$install = [System.IO.Path]::GetFullPath($InstallLocation)
if (Test-Path -LiteralPath $install) {
    Stop-Safely "Install location already exists. It will not be overwritten: $install"
}
$parent = Split-Path -Parent $install
if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
    Stop-Safely "Install-location parent does not exist: $parent"
}

Write-Host "Verified archive SHA-256: $observedHash"
Write-Host "Importing an independent copy as '$NewDistributionName'."
Write-Host 'This script never unregisters, replaces, overwrites, or deletes a WSL distribution.'
& $wsl.Source --import $NewDistributionName $install $archive --version 2
if ($LASTEXITCODE -ne 0) {
    Stop-Safely "wsl --import failed with exit code $LASTEXITCODE"
}

$packet = ConvertTo-BashLiteral $PacketPathInDistribution
$bundle = ConvertTo-BashLiteral $DeploymentBundlePathInDistribution
$runtime = ConvertTo-BashLiteral $RuntimeEnvironmentFileInDistribution
$qualification = ConvertTo-BashLiteral $QualificationOutputPathInDistribution
$operator = ConvertTo-BashLiteral $SignoffName
$qualificationCommand = @"
set -Eeuo pipefail
cd $packet
bash deployment/run_known_answer_qualification.sh --mode verify --bundle $bundle --runtime-env $runtime --output $qualification --signoff-name $operator
"@

Write-Host 'Running exact preflight and known-answer qualification inside the imported copy.'
& $wsl.Source -d $NewDistributionName -- bash -lc $qualificationCommand
if ($LASTEXITCODE -ne 0) {
    Stop-Safely @"
The imported distribution remains present but UNQUALIFIED because qualification failed.
No existing distribution was altered and no automatic unregister was attempted.
"@
}

Write-Host "Imported distribution '$NewDistributionName' passed the qualification command."
Write-Host "Review the signed report under $QualificationOutputPathInDistribution before real data."
