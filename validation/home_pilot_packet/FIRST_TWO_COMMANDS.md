# First Two Commands at Home

Run these in Windows PowerShell. The first expands the packet. The second
creates a WSL export in a new Windows directory; it is deliberately separate
from every WSL-side script.

```powershell
Expand-Archive -LiteralPath "$HOME\Downloads\MOSEQ_LEGACY_HOME_PILOT_WITH_DEPLOYMENT_2026-07-29.zip" -DestinationPath "$HOME\Downloads"
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$HOME\Downloads\MOSEQ_LEGACY_HOME_PILOT_WITH_DEPLOYMENT_2026-07-29\00_export_wsl_backup.ps1" -OutputDestination "$HOME\Documents\MoSeq2-WSL-Backups" -DistributionName "Ubuntu-22.04"
```

If the second command reports insufficient free space, rerun only that command
with a different explicit destination. Never skip the free-space check and
never add the export to an automatic run-all command.
