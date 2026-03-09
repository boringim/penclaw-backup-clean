# =============================================================================
# Tier 2: File-Level Backup - FINAL FIXED VERSION
# =============================================================================
# Hardcoded paths ONLY - no environment variable overrides
# =============================================================================

$ErrorActionPreference = "Stop"

# ABSOLUTE HARDCODED PATHS - DO NOT CHANGE
$OpenclawHome = "C:\Users\Administrator\.openclaw"
$OpenclawWorkspace = "C:\Users\Administrator\.openclaw\workspaces\oc-981e-isolated"
$BackupDir = "C:\Users\Administrator\backups\openclaw"
$LogDir = "C:\Users\Administrator\logs\openclaw-backup"

# Create directories
New-Item -ItemType Directory -Force -Path $LogDir, $BackupDir | Out-Null
$LogFile = Join-Path $LogDir "robocopy.log"

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $line = "[$ts] $msg"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

Log "=== Robocopy backup start ==="
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
    $DbScript = "C:\Users\Administrator\.openclaw\workspaces\oc-981e-isolated\backup-db.js"
    if (Test-Path $DbScript) {
        Log "Starting DB backup..."
        try {
            & node $DbScript 2>&1 | ForEach-Object { Log "[DB] $_" }
        } catch {
            Log "WARNING: DB backup failed: $_"
        }
    }
}

# Robocopy: OpenClaw home
$Dest1 = Join-Path $BackupDir "openclaw-home"
Log "Robocopy HOME: $OpenclawHome -> $Dest1"
$excludeDirs = @("node_modules", ".git", "__pycache__", "workspace", "workspaces")  # exclude nested workspaces
$excludeFiles = @("*.log", "*.tmp", "*.lock")
robocopy $OpenclawHome $Dest1 /MIR /NFL /NDL /NP /MT:4 /XD $excludeDirs /XF $excludeFiles /LOG+:$LogFile /TEE
if ($LASTEXITCODE -ge 8) {
    Log "ERROR: Robocopy home failed (code $LASTEXITCODE)"
} else {
    Log "SUCCESS: Home backed up"
}

# Robocopy: Workspace
$Dest2 = Join-Path $BackupDir "workspace"
Log "Robocopy WS: $OpenclawWorkspace -> $Dest2"
robocopy $OpenclawWorkspace $Dest2 /MIR /NFL /NDL /NP /MT:4 /XD $excludeDirs /XF $excludeFiles /LOG+:$LogFile /TEE
if ($LASTEXITCODE -ge 8) {
    Log "ERROR: Robocopy workspace failed (code $LASTEXITCODE)"
} else {
    Log "SUCCESS: Workspace backed up"
}

# Timestamped snapshot (keep 7)
$SnapshotDir = Join-Path $BackupDir "snapshots"
New-Item -ItemType Directory -Force -Path $SnapshotDir | Out-Null
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$SnapshotFile = Join-Path $SnapshotDir "openclaw-$timestamp.zip"
Log "Creating snapshot..."
try {
    Compress-Archive -Path $Dest1, $Dest2 -DestinationPath $SnapshotFile -Force -ErrorAction Stop
    $size = [math]::Round((Get-Item $SnapshotFile).Length / 1MB, 1)
    Log "SUCCESS: Snapshot created ($size MB)"
} catch {
    Log "ERROR: Snapshot failed: $_"
}

# Prune old snapshots (keep 7)
$snaps = Get-ChildItem $SnapshotDir -Filter "openclaw-*.zip" | Sort-Object Name -Descending
if ($snaps.Count -gt 7) {
    $toRemove = $snaps | Select-Object -Skip 7
    foreach ($snap in $toRemove) {
        Remove-Item $snap.FullName -Force
        Log "Pruned: $($snap.Name)"
    }
}

Log "=== Robocopy backup end ==="
exit 0
