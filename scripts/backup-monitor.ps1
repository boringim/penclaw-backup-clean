#!/usr/bin/env powershell
# Backup Monitor - 检查备份日志并发送告警
# ============================================
# 运行频率: 每1小时 (通过Windows定时任务)

$logDir = "C:\Users\Administrator\logs\openclaw-backup"
$alertFile = "C:\Users\Administrator\.openclaw\workspaces\oc-981e-feishu-group\backup-alerts.md"
$maxAlerts = 10  # 最多记录10条

# 需要检查的日志文件
$logFiles = @(
    "git.log",
    "robocopy.log",
    "backup-db.log",
    "file-backup.log",
    "backup-health.log"
)

# 错误关键词
$errorKeywords = @(
    "ERROR",
    "FAIL",
    "Exception",
    "fatal",
    "timeout",
    "denied",
    "access denied",
    "not found"
)

$alerts = @()

foreach ($log in $logFiles) {
    $logPath = Join-Path $logDir $log
    if (!(Test-Path $logPath)) { continue }

    # 检查最近24小时的内容
    $lines = Get-Content $logPath -Tail 100
    foreach ($line in $lines) {
        foreach ($keyword in $errorKeywords) {
            if ($line -match $keyword) {
                $alerts += [PSCustomObject]@{
                    Time = Get-Date -Format "yyyy-MM-dd HH:mm"
                    Log = $log
                    Message = $line.Trim()
                }
                break
            }
        }
    }
}

# 如果有告警，记录并发送
if ($alerts.Count -gt 0) {
    # 写入 alerts 文件 (保留最近 N 条)
    $existing = @()
    if (Test-Path $alertFile) {
        $existing = Get-Content $alertFile | Where-Object { $_ -match '^\[' } | Select-Object -Last $maxAlerts
    }

    $newEntries = $alerts | ForEach-Object { "[$($_.Time)] $($_.Log): $($_.Message)" }
    $allEntries = $newEntries + $existing | Select-Object -First $maxAlerts

    $allEntries | Set-Content $alertFile -Encoding UTF8

    # 构建通知消息
    $message = @"
🚨 **备份系统告警** 🚨
时间: $(Get-Date -Format "yyyy-MM-dd HH:mm")
发现 $($alerts.Count) 条异常记录:

$($alerts.Count > 5 ? "（仅显示前5条）`n`n" + ($alerts[0..4] | ForEach-Object { "- $($_.Log): $($_.Message)" }) : $alerts | ForEach-Object { "- $($_.Log): $($_.Message)" })

📁 详细日志: $logDir
📝 告警记录: $alertFile

请立即检查！
"@

    # 尝试通过 OpenClaw 发送 (需要设置环境变量)
    try {
        # 方法1: 写入临时文件，由 OpenClaw 自动读取
        $notifyFile = "C:\Users\Administrator\.openclaw\workspace\notifications\backup-alert-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
        New-Item -ItemType Directory -Force -Path (Split-Path $notifyFile) | Out-Null
        $message | Set-Content $notifyFile -Encoding UTF8
        Write-Host "Backup alert written to $notifyFile"
    } catch {
        Write-Host "Failed to send alert: $_"
    }

    # 同时输出到控制台（可以被定时任务捕获）
    Write-Host "`n[ALERT] Backup issues detected:" -ForegroundColor Red
    $alerts | ForEach-Object { Write-Host "  $($_.Log): $($_.Message)" -ForegroundColor Yellow }

} else {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✅ Backup check passed - no errors found"
}
