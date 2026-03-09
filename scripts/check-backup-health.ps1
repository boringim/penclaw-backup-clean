# =============================================================================
# Backup Health Check & Report
# =chedules: Daily 08:00, 12:00, 20:00
# =============================================================================

$ErrorActionPreference = "Stop"

# Paths
$LogDir = "C:\Users\Administrator\logs\openclaw-backup"
$GitLog = Join-Path $LogDir "git.log"
$RoboLog = Join-Path $LogDir "robocopy.log"
$SnapshotDir = "C:\Users\Administrator\backups\openclaw\snapshots"

function Get-LastRun {
    param([string]$LogFile, [string]$Pattern)
    if (Test-Path $LogFile) {
        $lines = Get-Content $LogFile | Where-Object { $_ -match $Pattern }
        if ($lines) { return $lines[-1] }
    }
    return $null
}

function Get-LatestSnapshot {
    if (Test-Path $SnapshotDir) {
        $snap = Get-ChildItem $SnapshotDir -Filter "openclaw-*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($snap) {
            return "$($snap.Name) ($([math]::Round($snap.Length/1MB,1)) MB at $($snap.LastWriteTime))"
        }
    }
    return "None found"
}

function Check-GitBackup {
    $lastSuccess = Get-LastRun -LogFile $GitLog -Pattern "SUCCESS: Pushed commit"
    $lastError = Get-LastRun -LogFile $GitLog -Pattern "ERROR:|WARNING:"
    $lastRun = Get-LastRun -LogFile $GitLog -Pattern "=== Git backup start ==="

    if ($lastSuccess -and ($lastSuccess -gt (Get-Date).AddHours(-2))) {
        return "✅ Git backup OK. Latest: $($lastSuccess.Substring(0,19))"
    } elseif ($lastError) {
        return "❌ Git backup error: $lastError"
    } elseif ($lastRun) {
        return "⚠️ Git backup running or stale (last: $($lastRun.Substring(0,19)))"
    } else {
        return "❓ No Git backup activity detected"
    }
}

function Check-Tier2Backup {
    $lastSuccess = Get-LastRun -LogFile $RoboLog -Pattern "SUCCESS: Workspace backed up"
    $lastError = Get-LastRun -LogFile $RoboLog -Pattern "ERROR:|Failed"
    $lastRun = Get-LastRun -LogFile $RoboLog -Pattern "=== Robocopy backup start ==="
    $snapshot = Get-LatestSnapshot

    if ($lastSuccess -and ($lastSuccess -gt (Get-Date).AddHours(-4))) {
        return "✅ Tier 2 OK. Latest: $($lastSuccess.Substring(0,19)) | Snapshot: $snapshot"
    } elseif ($lastError) {
        return "❌ Tier 2 error: $lastError"
    } elseif ($lastRun) {
        return "⚠️ Tier 2 running or stale (last: $($lastRun.Substring(0,19)))"
    } else {
        return "❓ No Tier 2 activity detected"
    }
}

# Generate report
$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @"
=== Backup Health Check ===
Time: $time

$(Check-GitBackup)

$(Check-Tier2Backup)

"@

# Write to console and log
$LogFile = Join-Path $LogDir "backup-health.log"
Add-Content -Path $LogFile -Value $report -Encoding UTF8
Write-Host $report

# Send to OpenClaw main session (if available)
try {
    $sessions = sessions_send -message $report -label "backup-monitor" -timeoutSeconds 5 2>$null
} catch {
    # No active session or messaging not available - just log
}

exit 0
