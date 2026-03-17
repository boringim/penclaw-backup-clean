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
$SnapshotFile = Join-Path $SnapshotDir "openclaw-$timestamp.tar"
Log "Creating snapshot..."
try {
    # Use tar to avoid file lock issues with Compress-Archive
    tar -cf "`"$SnapshotFile`"" -C $BackupDir openclaw-home $Dest2Name 2>$null
    if ($LASTEXITCODE -ne 0) { throw "tar exited with code $LASTEXITCODE" }
    $size = [math]::Round((Get-Item $SnapshotFile).Length / 1MB, 1)
    Log "SUCCESS: Snapshot created ($size MB)"
} catch {
    Log "ERROR: Snapshot failed: $_"
}

# Prune old snapshots (keep 7)
$snaps = Get-ChildItem $SnapshotDir -Filter "openclaw-*.tar" | Sort-Object Name -Descending
if ($snaps.Count -gt 7) {
    $toRemove = $snaps | Select-Object -Skip 7
    foreach ($snap in $toRemove) {
        Remove-Item $snap.FullName -Force
        Log "Pruned: $($snap.Name)"
    }
}

Log "=== Robocopy backup end (Manual) ==="
exit 0
