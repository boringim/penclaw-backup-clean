# =============================================================================
# Tier 1: Git Backup - Repository-Synced Configuration
# =============================================================================
# Backs up whitelisted configuration files to a clean GitHub repository.
# Uses SSH authentication. Continues on DB backup failure.
# =============================================================================

$ErrorActionPreference = "Stop"

# ABSOLUTE HARDCODED PATHS
$OpenclawWorkspace = "C:\Users\Administrator\.openclaw\workspaces\oc-981e-isolated"
$BackupDir = "C:\Users\Administrator\backups\openclaw"
$LogDir = "C:\Users\Administrator\logs\openclaw-backup"
$GitRepoUrl = "git@github.com:boringim/penclaw-backup-clean.git"
$GitBranch = "master"

# Create log dir
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$LogFile = Join-Path $LogDir "git.log"

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $line = "[$ts] $msg"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

Log "=== Git backup start ==="
Log "Workspace: $OpenclawWorkspace"
Log "BackupDir: $BackupDir"

# Validate workspace
if (-not (Test-Path $OpenclawWorkspace)) {
    Log "ERROR: Workspace not found: $OpenclawWorkspace"
    exit 1
}

# Change to workspace root for Git operations
Set-Location $OpenclawWorkspace

# Ensure Git repo exists
if (-not (Test-Path ".git")) {
    Log "Initializing Git repository..."
    git init | Out-Null
    git remote add origin "$GitRepoUrl" | Out-Null
}

# Optional: Database backup (best effort)
$DbScript = Join-Path $OpenclawWorkspace "backup-db.js"
if (Test-Path $DbScript) {
    Log "Starting DB backup..."
    try {
        $dbOutput = & node $DbScript 2>&1
        foreach ($line in $dbOutput) { Log "[DB] $line" }
    } catch {
        Log "WARNING: DB backup failed: $_"
    }
} else {
    Log "WARNING: DB backup script not found: $DbScript"
}

# WHITELIST: Only track essential configuration files
$whitelist = @(
    # Core workspace config
    "AGENTS.md",
    "HEARTBEAT.md",
    "IDENTITY.md",
    "SOUL.md",
    "TOOLS.md",
    "USER.md",
    ".env",

    # Memory & logs (selected)
    "MEMORY.md",
    "memory",

    # Backup scripts (essential for recovery)
    "backup-git.ps1",
    "backup-db.js",
    "package.json",
    "scripts",

    # OpenClaw core (subset)
    ".openclaw/config",
    ".openclaw/credentials",
    ".openclaw/cron",
    ".openclaw/identity",
    ".openclaw/logs",
    ".openclaw/memory",
    ".openclaw/security_logs",
    ".openclaw/security_reports"
)

# Clean previous index
git rm -r --cached --ignore-unmatch * | Out-Null

# Add whitelisted paths
foreach ($item in $whitelist) {
    $path = Join-Path $OpenclawWorkspace $item
    if (Test-Path $path) {
        Log "Adding: $item"
        git add "$item" | Out-Null
    } else {
        Log "SKIP (not found): $item"
    }
}

# Commit if there are changes
$status = git status --porcelain
if ($status) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMsg = "backup: $ts"
    Log "Committing changes..."
    git commit -m "$commitMsg" | Out-Null
    Log "Pushing to origin..."
    $pushOutput = git push origin "$GitBranch" 2>&1
    foreach ($line in $pushOutput) { Log "[PUSH] $line" }
    if ($LASTEXITCODE -eq 0) {
        Log "SUCCESS: Pushed commit"
    } else {
        Log "ERROR: Git push failed (exit code $LASTEXITCODE)"
    }
} else {
    Log "No changes to commit"
}

Log "=== Git backup end ==="
exit 0
