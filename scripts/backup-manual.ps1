# =============================================================================
# Tier 2: File-Level Backup - Manual Run for oc-981e-feishu-group
# =============================================================================

$ErrorActionPreference = "Stop"

# ABSOLUTE PATHS for current workspace
$OpenclawHome = "C:\Users\Administrator\.openclaw"
$OpenclawWorkspace = "C:\Users\Administrator\.openclaw\workspaces\oc-981e-feishu-group"
$BackupDir = "C:\Users\Administrator\backups\openclaw"
$LogDir = "C:\Users\Administrator\logs\openclaw-backup"

# Create directories
New-Item -ItemType Directory -Force -Path $LogDir, $BackupDir | Out-Null
$LogFile = Join-Path $LogDir "robocopy-manual-$(Get-Date -Format 'yyyy-MMdd_HHmmss').log"

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $line = "[$ts] $msg"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Update-RecoveryDoc($BackupRoot, $SnapshotFilePath, $WorkspaceDirName) {
    $file = Get-Item $SnapshotFilePath
    $version = [System.IO.Path]::GetFileName($SnapshotFilePath)
    $sizeMb = [math]::Round($file.Length / 1MB, 2)
    $updatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $updatedAtIso = (Get-Date).ToString('s')
    $docPath = Join-Path $BackupRoot 'RECOVER_FROM_FILE_BACKUP.md'
    $jsonPath = Join-Path $BackupRoot 'latest.json'
    $homeMirror = 'C:\Users\Administrator\backups\openclaw\openclaw-home'
    $workspaceMirror = "C:\Users\Administrator\backups\openclaw\$WorkspaceDirName"
    $content = @"
# OpenClaw File-Level Backup Recovery Guide

This file is auto-updated after each successful file-level backup.
Use this document as the primary restore reference for mirror and snapshot recovery.

## Latest snapshot
- Backup type: file-level mirror plus compressed snapshot
- Latest snapshot: $version
- Snapshot path: $SnapshotFilePath
- Snapshot size: $sizeMb MB
- Current HOME mirror: $homeMirror
- Current WORKSPACE mirror: $workspaceMirror
- Updated at: $updatedAt

## Recommended restore method

### Method A: restore from snapshot
1. Stop OpenClaw.
2. Backup the current broken state first.
3. Extract the snapshot to a temporary directory:
   tar -xzf "$SnapshotFilePath" -C "C:\Users\Administrator\backups\openclaw\restore-temp"
4. Restore the contents of openclaw-home to:
   C:\Users\Administrator\.openclaw
5. If needed, also reference the workspace copy at:
   C:\Users\Administrator\backups\openclaw\restore-temp\$WorkspaceDirName
6. Start OpenClaw and verify.

### Method B: restore directly from mirror
- HOME mirror source:
  $homeMirror
- Restore target:
  C:\Users\Administrator\.openclaw

## Included
- .openclaw core files
- key memory, agents, backup, and config
- current workspace mirror

## Excluded
- browser
- logs
- caches
- experiments/camoufox-wrapper/profiles

## Post-restore checks
- openclaw.json exists
- memory, agents, and backup exist
- workspace is complete
- OpenClaw starts normally

## Notes
- The latest snapshot value is refreshed automatically after each successful file-level backup.
- If multiple snapshots exist, prefer the version listed in this file.
"@
    Set-Content -Path $docPath -Value $content -Encoding UTF8

    $json = [pscustomobject]@{
        schema = 'openclaw.backup.latest.v1'
        type = 'file-level-mirror-plus-snapshot'
        version = $version
        snapshot_path = $SnapshotFilePath
        snapshot_size_mb = $sizeMb
        home_mirror = $homeMirror
        workspace_mirror = $workspaceMirror
        updated_at = $updatedAt
        updated_at_iso = $updatedAtIso
        restore_doc = $docPath
        included = @('.openclaw core files','key memory, agents, backup, and config','current workspace mirror')
        excluded = @('browser','logs','caches','experiments/camoufox-wrapper/profiles')
    } | ConvertTo-Json -Depth 4
    Set-Content -Path $jsonPath -Value $json -Encoding UTF8
}

Log "=== Robocopy backup start (Manual) ==="
Log "SRC_HOME: $OpenclawHome"
Log "SRC_WS:  $OpenclawWorkspace"
Log "DEST:    $BackupDir"

# Validate sources exist
if (-not (Test-Path $OpenclawHome)) {
    Log "ERROR: Source home not found: $OpenclawHome"
    exit 1
}
if (-not (Test-Path $OpenclawWorkspace)) {
    Log "ERROR: Source workspace not found: $OpenclawWorkspace"
    exit 1
}

# Database backup (optional)
$Node = Get-Command node -ErrorAction SilentlyContinue
if ($Node) {
    $DbScript = Join-Path $OpenclawWorkspace "backup-db.js"
    if (Test-Path $DbScript) {
        Log "Starting DB backup..."
        try {
            & node $DbScript 2>&1 | ForEach-Object { Log "[DB] $_" }
        } catch {
            Log "WARNING: DB backup failed: $_"
        }
    } else {
        Log "DB backup script not found at $DbScript (skipping)"
    }
}

function Invoke-RobocopyLogged($Source, $Destination, $DirsToExclude, $FilesToExclude, $Label) {
    Log "Robocopy ${Label}: $Source -> $Destination"
    robocopy $Source $Destination /MIR /NFL /NDL /NP /MT:4 /R:1 /W:1 /XD $DirsToExclude /XF $FilesToExclude /LOG+:$LogFile /TEE
    $code = $LASTEXITCODE
    if ($code -ge 8) {
        Log "ERROR: Robocopy $Label failed (code $code)"
        return $false
    }

    Log "SUCCESS: $Label backed up (robocopy code $code)"
    return $true
}

# Robocopy: OpenClaw home (entire .openclaw directory)
$Dest1 = Join-Path $BackupDir "openclaw-home"
$excludeDirs = @(
    "node_modules", ".git", "__pycache__", "workspace", "workspaces",
    "browser", "logs",
    "profiles", "Cache", "Cache_Data", "Code Cache"
)
$excludeFiles = @("*.log", "*.tmp", "*.lock", "Cookies", "Cookies-journal", "Tabs_*")
$homeOk = Invoke-RobocopyLogged -Source $OpenclawHome -Destination $Dest1 -DirsToExclude $excludeDirs -FilesToExclude $excludeFiles -Label "HOME"

# Robocopy: Workspace (specific workspace)
$Dest2Name = "workspace-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$Dest2 = Join-Path $BackupDir $Dest2Name
$wsOk = Invoke-RobocopyLogged -Source $OpenclawWorkspace -Destination $Dest2 -DirsToExclude $excludeDirs -FilesToExclude $excludeFiles -Label "WORKSPACE"

# Timestamped snapshot (keep 7)
$SnapshotDir = Join-Path $BackupDir "snapshots"
New-Item -ItemType Directory -Force -Path $SnapshotDir | Out-Null
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$SnapshotFile = Join-Path $SnapshotDir "openclaw-$timestamp.tar.gz"
Log "Creating compressed snapshot..."
try {
    # Snapshot only the already-filtered mirror outputs, and compress to save space
    & tar -czf $SnapshotFile -C $BackupDir openclaw-home $Dest2Name
    if ($LASTEXITCODE -ne 0) { throw "tar exited with code $LASTEXITCODE" }
    $size = [math]::Round((Get-Item $SnapshotFile).Length / 1MB, 1)
    Log "SUCCESS: Snapshot created ($size MB)"
    Update-RecoveryDoc -BackupRoot $BackupDir -SnapshotFilePath $SnapshotFile -WorkspaceDirName $Dest2Name
} catch {
    Log "ERROR: Snapshot failed: $_"
}

# Remove uncompressed legacy snapshots if any exist for same timestamp pattern
Get-ChildItem $SnapshotDir -Filter "openclaw-*.tar" -ErrorAction SilentlyContinue | ForEach-Object {
    if (-not (Test-Path ($_.FullName + '.gz'))) {
        Log "Legacy uncompressed snapshot retained: $($_.Name)"
    }
}

# Prune old snapshots (keep 7, prefer new .tar.gz snapshots)
$snaps = Get-ChildItem $SnapshotDir -File | Where-Object { $_.Name -like 'openclaw-*.tar' -or $_.Name -like 'openclaw-*.tar.gz' } | Sort-Object Name -Descending
if ($snaps.Count -gt 7) {
    $toRemove = $snaps | Select-Object -Skip 7
    foreach ($snap in $toRemove) {
        Remove-Item $snap.FullName -Force
        Log "Pruned: $($snap.Name)"
    }
}

Log "=== Robocopy backup end (Manual) ==="
exit 0
