$backupDir = 'C:\Users\Administrator\openclaw-backups'
$timestamp = Get-Date -Format 'yyyy-MM-dd_HHmm'
$backupFile = Join-Path $backupDir ("openclaw-{0}.tar.gz" -f $timestamp)

# 创建备份目录
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

# 执行备份（排除 completions 和日志文件）
tar -czf $backupFile --exclude='completions' --exclude='*.log' -C 'C:\Users\Administrator' .openclaw

# 输出结果
if (Test-Path $backupFile) {
    $size = (Get-Item $backupFile).Length / 1MB
    Write-Output "BACKUP_SUCCESS:$($backupFile):$($size.ToString('F2'))"
} else {
    Write-Output "BACKUP_FAILED:Backup file not created"
}
