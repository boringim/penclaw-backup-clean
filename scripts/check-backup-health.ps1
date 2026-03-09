# Backup Health Check
# Runs: 08:00, 12:00, 20:00 daily

$ErrorActionPreference = "Stop"

$LogDir = "C:\Users\Administrator\logs\openclaw-backup"
$GitLog = Join-Path $LogDir "git.log"
$RoboLog = Join-Path $LogDir "robocopy.log"
$SnapshotDir = "C:\Users\Administrator\backups\openclaw\snapshots"
$HealthLog = Join-Path $LogDir "backup-health.log"

function Get-LastLine($LogFile, $Pattern) {
    if (-not (Test-Path $LogFile)) { return $null }
    $lines = Get-Content $LogFile
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        if ($lines[$i] -match $Pattern) { return $lines[$i] }
    }
    return $null
}

function Get-CompletedRuns($LogFile, $StartPattern, $EndPattern) {
    if (-not (Test-Path $LogFile)) { return 0 }
    $lines = Get-Content $LogFile
    $count = 0
    $inRun = $false
    foreach ($line in $lines) {
        if ($line -match $StartPattern) { $inRun = $true }
        if ($inRun -and $line -match $EndPattern) { $count++; $inRun = $false }
    }
    return $count
}

function Parse-Time($Line) {
    if ($Line -notmatch '\[(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})\]') { return $null }
    $ts = $matches[1]
    return [DateTime]::ParseExact($ts, "yyyy-MM-ddTHH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture)
}

# Git backup check
$gitLastStart = Get-LastLine $GitLog "=== Git backup start ==="
$gitLastEnd = Get-LastLine $GitLog "=== Git backup end ==="
$gitRuns = Get-CompletedRuns $GitLog "=== Git backup start ===" "=== Git backup end ==="

$gitStatus = "❓ Unknown"
if ($gitLastEnd -and $gitLastStart) {
    $startTime = Parse-Time $gitLastStart
    $endTime = Parse-Time $gitLastEnd
    if ($endTime -gt $startTime) {
        $gitStatus = "✅ Git backup completed at $($endTime.ToString('HH:mm'))"
    }
} elseif ($gitLastStart) {
    $startTime = Parse-Time $gitLastStart
    $age = (Get-Date) - $startTime
    if ($age.TotalMinutes -lt 15) {
        $gitStatus = "⏳ Git backup running"
    } else {
        $gitStatus = "❌ Git backup stalled (started $($startTime.ToString('HH:mm')))"
    }
} else {
    $gitStatus = "❓ No Git backup activity"
}

# Tier 2 check
$tier2LastStart = Get-LastLine $RoboLog "=== Robocopy backup start ==="
$tier2LastEnd = Get-LastLine $RoboLog "=== Robocopy backup end ==="
$tier2Runs = Get-CompletedRuns $RoboLog "=== Robocopy backup start ===" "=== Robocopy backup end ==="

$tier2Status = "❓ Unknown"
$snapshotInfo = "None"
if (Test-Path $SnapshotDir) {
    $latest = Get-ChildItem $SnapshotDir -Filter "openclaw-*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest) {
        $snapshotInfo = "$($latest.Name) ($([math]::Round($latest.Length/1MB,1)) MB)"
    }
}

if ($tier2LastEnd -and $tier2LastStart) {
    $startTime = Parse-Time $tier2LastStart
    $endTime = Parse-Time $tier2LastEnd
    if ($endTime -gt $startTime) {
        $wsOk = (Get-LastLine $RoboLog "SUCCESS: Workspace backed up") -like "*SUCCESS*"
        $snapOk = (Get-LastLine $RoboLog "SUCCESS: Snapshot created") -like "*SUCCESS*"
        if ($wsOk -and $snapOk) {
            $tier2Status = "✅ Tier 2 OK at $($endTime.ToString('HH:mm')) | Snapshot: $snapshotInfo"
        } else {
            $tier2Status = "⚠️ Tier 2 completed with issues"
        }
    }
} elseif ($tier2LastStart) {
    $startTime = Parse-Time $tier2LastStart
    $age = (Get-Date) - $startTime
    if ($age.TotalMinutes -lt 20) {
        $tier2Status = "⏳ Tier 2 possibly running"
    } else {
        $tier2Status = "❌ Tier 2 stalled (started $($startTime.ToString('HH:mm')))"
    }
} else {
    $tier2Status = "❓ No Tier 2 activity"
}

# Build report
$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @"
=== Backup Health Check ===
Time: $time

$gitStatus

$tier2Status

"@

# Log
Add-Content -Path $HealthLog -Value $report -Encoding UTF8
Write-Host $report

# Try to send to main session (non-fatal)
try {
    $null = sessions_send -message $report -label "backup-monitor" -timeoutSeconds 3 -ErrorAction SilentlyContinue
} catch { }

exit 0
