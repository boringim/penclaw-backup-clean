#!/usr/bin/env powershell
# 创建备份监控定时任务
# =======================

$taskName = "OpenClaw-BackupMonitor"
$scriptPath = "C:\Users\Administrator\.openclaw\workspaces\oc-981e-feishu-group\scripts\backup-monitor.ps1"
$description = "Monitor OpenClaw backup logs and send alerts"

# 检查任务是否已存在
$existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Task '$taskName' already exists. Updating..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# 创建基本触发器：每小时运行一次
$trigger = New-ScheduledTaskTrigger -Daily -At 0:00 -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration (New-TimeSpan -Days 3650)

# 创建操作
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# 创建设置
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable

# 创建任务
Register-ScheduledTask -TaskName $taskName -Description $description -Trigger $trigger -Action $action -Settings $settings -RunLevel Limited

Write-Host "✅ Scheduled task '$taskName' created successfully." -ForegroundColor Green
Write-Host "   Runs every hour, checks backup logs, and sends alerts." -ForegroundColor Cyan
Write-Host "`nTo view task: Get-ScheduledTask -TaskName $taskName" -ForegroundColor Gray
Write-Host "To test run: Start-ScheduledTask -TaskName $taskName" -ForegroundColor Gray
