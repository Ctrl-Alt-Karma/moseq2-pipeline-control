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
& $wsl.Source --list --verbose
if ($LASTEXITCODE -ne 0) {
    Stop-Safely 'wsl --list --verbose failed.'
}

$installed = @(
    & $wsl.Source --list --quiet |
        ForEach-Object { ($_ -replace "`0", '').Trim() } |
        Where-Object { $_ }
)
if ($LASTEXITCODE -ne 0) {
    Stop-Safely 'wsl --list --quiet failed.'
}
if ($DistributionName -notin $installed) {
    Stop-Safely "Distribution '$DistributionName' was not found. No export was attempted."
}

$destination = [System.IO.Path]::GetFullPath($OutputDestination)
if (-not (Test-Path -LiteralPath $destination)) {
    New-Item -ItemType Directory -Path $destination | Out-Null
}
$destinationItem = Get-Item -LiteralPath $destination
if (-not $destinationItem.PSIsContainer) {
    Stop-Safely "OutputDestination must be a directory: $destination"
}

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
    Stop-Safely "wsl --export failed with exit code $LASTEXITCODE"
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
