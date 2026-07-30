# First Three PowerShell Commands After Verifier Approval

Run these three commands, in order, in the same Windows PowerShell session.
The first expands the corrected packet. The second explicitly creates the
confirmed local backup directory, resolves and displays its final path, and
fails if that path contains a OneDrive component. The third calls the WSL
export with the exact destination and distribution name. It is deliberately
separate from every WSL-side script.

```powershell
Expand-Archive -LiteralPath "$HOME\Downloads\MOSEQ_LEGACY_HOME_PILOT_WITH_DEPLOYMENT_CORRECTED_2026-07-29.zip" -DestinationPath "$HOME\Downloads"
```

```powershell
$null = New-Item -ItemType Directory -Path 'C:\Users\AJM\Documents\MoSeq2-WSL-Backups' -Force; $BackupDestination = (Resolve-Path -LiteralPath 'C:\Users\AJM\Documents\MoSeq2-WSL-Backups').Path; Write-Host "Resolved backup destination: $BackupDestination"; if ($BackupDestination -match '(?i)(^|[\\/])OneDrive[^\\/]*([\\/]|$)') { throw "Backup destination contains a OneDrive component: $BackupDestination" }
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$HOME\Downloads\MOSEQ_LEGACY_HOME_PILOT_WITH_DEPLOYMENT_CORRECTED_2026-07-29\00_export_wsl_backup.ps1" -OutputDestination $BackupDestination -DistributionName 'Ubuntu-22.04'
```

The export script rechecks that `Ubuntu-22.04` is `Stopped`. If it is
`Running`, the script fails without stopping it. If the third command reports
insufficient free space, rerun only that command
with a different explicit destination. Never skip the free-space check and
never add the export to an automatic run-all command.
