# Reschedule Backup Monitor Tasks
# 目的：将备份健康检查任务从整点调整到半点的，避免与备份任务重叠
# 使用方法：以管理员身份运行 PowerShell，执行此脚本

Write-Host "开始调整 Backup-Monitor 任务触发时间..." -ForegroundColor Cyan

# 定义任务和新时间映射
$taskTimes = @{
    "Backup-Monitor-0800" = "08:30"
    "Backup-Monitor-1200" = "12:30"
    "Backup-Monitor-2000" = "20:30"
}

foreach ($taskName in $taskTimes.Keys) {
    $newTime = $taskTimes[$taskName]
    
    # 检查任务是否存在
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if (-not $task) {
        Write-Host "❌ 任务不存在: $taskName" -ForegroundColor Red
        continue
    }
    
    # 创建新触发器（每日指定时间）
    $trigger = New-ScheduledTaskTrigger -Daily -At $newTime
    
    # 应用新触发器
    Set-ScheduledTask -TaskName $taskName -Trigger $trigger
    
    # 验证
    $updated = Get-ScheduledTask -TaskName $taskName
    $actualTime = $updated.Triggers[0].StartBoundary.ToString("HH:mm")
    
    if ($actualTime -eq $newTime) {
        Write-Host "✅ $taskName -> $newTime" -ForegroundColor Green
    } else {
        Write-Host "⚠️  $taskName 实际时间: $actualTime (期望: $newTime)" -ForegroundColor Yellow
    }
}

Write-Host "`n所有任务已更新！验证结果：" -ForegroundColor Cyan
$taskTimes.Keys | ForEach-Object {
    $t = Get-ScheduledTask -TaskName $_
    $time = $t.Triggers[0].StartBoundary.ToString("HH:mm")
    Write-Host "  $_ : $time"
}

Write-Host "`n完成。请检查任务计划程序确认 변경사항。" -ForegroundColor Green