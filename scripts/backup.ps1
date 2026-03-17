$backupDir = 'C:\Users\Administrator\openclaw-backups'
$timestamp = Get-Date -Format 'yyyy-MM-dd_HHmm'
$backupFile = Join-Path $backupDir ("openclaw-{0}.tar.gz" -f $timestamp)
$tempStage = Join-Path $backupDir ("staging-{0}" -f $timestamp)

# 创建备份目录
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
if (Test-Path $tempStage) { Remove-Item $tempStage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $tempStage | Out-Null

# 先用 robocopy 生成一个稳定的临时镜像，避免 tar 直接读取运行中事务文件时报错
$source = 'C:\Users\Administrator\.openclaw'
$stagedOpenclaw = Join-Path $tempStage '.openclaw'
$excludeDirs = @('node_modules','.git','__pycache__','workspace','workspaces','browser','logs','profiles','Cache','Cache_Data','Code Cache')
$excludeFiles = @('*.log','*.tmp','*.lock','Cookies','Cookies-journal','Tabs_*')
robocopy $source $stagedOpenclaw /MIR /R:1 /W:1 /MT:4 /XD $excludeDirs /XF $excludeFiles /NFL /NDL /NP | Out-Null
$robocopyCode = $LASTEXITCODE
if ($robocopyCode -ge 8) {
    throw "STAGING_FAILED: robocopy exit code $robocopyCode"
}

# 再压缩稳定镜像
& tar -czf $backupFile -C $tempStage .openclaw
$tarCode = $LASTEXITCODE

# 清理 staging
Remove-Item $tempStage -Recurse -Force -ErrorAction SilentlyContinue

function Update-RecoveryDoc($BackupRoot, $BackupFilePath) {
    $file = Get-Item $BackupFilePath
    $version = [System.IO.Path]::GetFileName($BackupFilePath)
    $sizeMb = [math]::Round($file.Length / 1MB, 2)
    $updatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $updatedAtIso = (Get-Date).ToString('s')
    $docPath = Join-Path $BackupRoot 'RECOVER_FROM_BACKUP.md'
    $jsonPath = Join-Path $BackupRoot 'latest.json'
    $content = @"
# OpenClaw Backup Recovery Guide

This file is auto-updated after each successful backup.
Use this document as the primary restore reference.

## Latest backup
- Backup type: compressed primary backup
- Latest version: $version
- File path: $BackupFilePath
- File size: $sizeMb MB
- Updated at: $updatedAt

## Included
- .openclaw core configuration and state
- memory
- agents
- backup
- workspaces, scripts, key config files

## Excluded
- browser runtime state and login sessions
- logs
- runtime caches
- experiments/camoufox-wrapper/profiles

## Recommended restore steps
1. Stop OpenClaw and related background processes.
2. Backup the current broken state before replacing anything.
3. Remove or move away the old directory:
   C:\Users\Administrator\.openclaw
4. Extract this backup under:
   C:\Users\Administrator
   Command:
   tar -xzf "$BackupFilePath" -C "C:\Users\Administrator"
5. Confirm these paths exist after restore:
   C:\Users\Administrator\.openclaw\openclaw.json
   C:\Users\Administrator\.openclaw\memory
   C:\Users\Administrator\.openclaw\agents
   C:\Users\Administrator\.openclaw\workspaces
6. Start OpenClaw.
7. If browser login state or experiment profiles are needed, restore them separately from a cold backup.

## Post-restore checks
- openclaw.json exists
- memory works normally
- agents and workspaces are present
- gateway and sessions can start
- if anything is wrong, roll back to the previous known-good backup

## Notes
- The latest version is refreshed automatically after each successful backup.
- If multiple backups exist, prefer the version listed in this file.
"@
    Set-Content -Path $docPath -Value $content -Encoding UTF8

    $json = [pscustomobject]@{
        schema = 'openclaw.backup.latest.v1'
        type = 'primary-compressed-backup'
        version = $version
        file_path = $BackupFilePath
        size_mb = $sizeMb
        updated_at = $updatedAt
        updated_at_iso = $updatedAtIso
        restore_doc = $docPath
        included = @('.openclaw core configuration and state','memory','agents','backup','workspaces, scripts, key config files')
        excluded = @('browser runtime state and login sessions','logs','runtime caches','experiments/camoufox-wrapper/profiles')
    } | ConvertTo-Json -Depth 4
    Set-Content -Path $jsonPath -Value $json -Encoding UTF8
}

# 输出结果
if ($tarCode -eq 0 -and (Test-Path $backupFile)) {
    $size = (Get-Item $backupFile).Length / 1MB
    Update-RecoveryDoc -BackupRoot $backupDir -BackupFilePath $backupFile
    Write-Output "BACKUP_SUCCESS:$($backupFile):$($size.ToString('F2'))"
} else {
    Write-Output "BACKUP_FAILED:tar exit code $tarCode"
}
