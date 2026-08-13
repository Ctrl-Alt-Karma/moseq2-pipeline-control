[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputDestination,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$DistributionName = 'Ubuntu-22.04',

    [Parameter()]
    [ValidateRange(1GB, [long]::MaxValue)]
    [long]$MinimumFreeBytes = 20GB
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Stop-Safely {
    param([string]$Message)
    throw $Message
}

$wsl = Get-Command wsl.exe -ErrorAction Stop

Write-Host 'Installed WSL distributions:'
$verboseLines = @(
    & $wsl.Source --list --verbose |
        ForEach-Object { ($_ -replace "`0", '').TrimEnd() }
)
if ($LASTEXITCODE -ne 0) {
    Stop-Safely 'wsl --list --verbose failed.'
}
$verboseLines | ForEach-Object { Write-Host $_ }

$distributionStates = @()
foreach ($line in $verboseLines) {
    $parsed = [regex]::Match(
        $line,
        '^\s*(?:\*\s*)?(?<Name>\S+)\s+(?<State>\S+)\s+(?<Version>\d+)\s*$'
    )
    if (
        $parsed.Success -and
        $parsed.Groups['Name'].Value -ceq $DistributionName
    ) {
        $distributionStates += $parsed.Groups['State'].Value
    }
}
if ($distributionStates.Count -eq 0) {
    Stop-Safely "Distribution '$DistributionName' was not found. No export was attempted."
}
if ($distributionStates.Count -ne 1) {
    Stop-Safely "Distribution '$DistributionName' appeared more than once. No export was attempted."
}

$distributionState = $distributionStates[0]
if ($distributionState -ceq 'Running') {
    Stop-Safely (
        "Distribution '$DistributionName' is Running. Stop it manually, confirm " +
        "it reports Stopped, and rerun. This script will not stop, terminate, " +
        'shut down, or unregister any distribution.'
    )
}
if ($distributionState -cne 'Stopped') {
    Stop-Safely (
        "Distribution '$DistributionName' must be Stopped before export; " +
        "observed state '$distributionState'. No export was attempted."
    )
}
Write-Host "Verified WSL state: $DistributionName is Stopped."

$destination = [System.IO.Path]::GetFullPath($OutputDestination)
if (-not (Test-Path -LiteralPath $destination)) {
    New-Item -ItemType Directory -Path $destination | Out-Null
}
$destinationItem = Get-Item -LiteralPath $destination
if (-not $destinationItem.PSIsContainer) {
    Stop-Safely "OutputDestination must be a directory: $destination"
}
if ($destination -match '(?i)(^|[\\/])OneDrive[^\\/]*([\\/]|$)') {
    Stop-Safely "OutputDestination must not contain a OneDrive component: $destination"
}
Write-Host "Resolved non-OneDrive destination: $destination"

$driveRoot = [System.IO.Path]::GetPathRoot($destination)
$drive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($driveRoot.TrimEnd('\'))'"
if ($null -eq $drive) {
    Stop-Safely "Could not determine free space for $driveRoot"
}
Write-Host ("Destination free bytes: {0}" -f [long]$drive.FreeSpace)
Write-Host ("Required minimum free bytes: {0}" -f $MinimumFreeBytes)
if ([long]$drive.FreeSpace -lt $MinimumFreeBytes) {
    Stop-Safely 'Destination does not meet the minimum free-space requirement. No export was attempted.'
}

$stamp = Get-Date -Format 'yyyyMMddTHHmmss'
$safeDistribution = $DistributionName -replace '[^A-Za-z0-9._-]', '_'
$archive = Join-Path $destination "${safeDistribution}_${stamp}.tar"
if (Test-Path -LiteralPath $archive) {
    Stop-Safely "Refusing to overwrite existing archive: $archive"
}

Write-Host "Exporting '$DistributionName' read-only to '$archive'."
Write-Host 'This script never unregisters, deletes, replaces, imports, or alters a WSL distribution.'
& $wsl.Source --export $DistributionName $archive --format tar
if ($LASTEXITCODE -ne 0) {
    Stop-Safely (
        "wsl --export failed with exit code $LASTEXITCODE. Any partial archive " +
        'is retained for inspection; this script does not delete it automatically.'
    )
}

$archiveItem = Get-Item -LiteralPath $archive
$hash = Get-FileHash -Algorithm SHA256 -LiteralPath $archive
$receipt = [ordered]@{
    distribution = $DistributionName
    archive = $archiveItem.FullName
    bytes = [long]$archiveItem.Length
    sha256 = $hash.Hash.ToLowerInvariant()
    exported_utc = (Get-Date).ToUniversalTime().ToString('o')
}
$receiptPath = "${archive}.sha256.json"
$receipt | ConvertTo-Json | Set-Content -LiteralPath $receiptPath -Encoding utf8

Write-Host "Archive bytes: $($receipt.bytes)"
Write-Host "Archive SHA-256: $($receipt.sha256)"
Write-Host "Receipt: $receiptPath"
