#!/usr/bin/env powershell
# Quick Start - 启动所有增强服务（不阻塞）
Write-Host "🚀 Starting OpenClaw Enhancement Services..." -ForegroundColor Green

# 1. RelayPlane
Write-Host "`n[1/2] Starting RelayPlane (port 3001)..." -ForegroundColor Yellow
try {
    $relayProc = Start-Process -FilePath "relayplane-proxy" -WindowStyle Hidden -PassThru -ErrorAction Stop
    Write-Host "   ✅ Started (PID $($relayProc.Id))"
} catch {
    Write-Host "   ❌ Failed to start RelayPlane: $_" -ForegroundColor Red
}

# 2. ClawSec
Write-Host "[2/2] Starting ClawSec Monitor (port 8888)..." -ForegroundColor Yellow
$python = "C:\Users\Administrator\AppData\Local\Programs\Python\Python310\python.exe"
$clawsecScript = "C:\Users\Administrator\.openclaw\workspace\skills\clawsec-monitor-main\clawsec-monitor.py"
try {
    $clawsecProc = Start-Process -FilePath $python -ArgumentList "`"$clawsecScript`" start --no-mitm" -WindowStyle Hidden -PassThru -ErrorAction Stop
    Write-Host "   ✅ Started (PID $($clawsecProc.Id))"
} catch {
    Write-Host "   ❌ Failed to start ClawSec: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 2

# 验证端口
Write-Host "`n📊 Verifying ports..." -ForegroundColor Cyan
$ports = @(3001, 8888)
foreach ($port in $ports) {
    $listening = netstat -ano | Select-String "LISTEN *:$port"
    if ($listening) {
        Write-Host ("   ✅ Port {0}: listening" -f $port) -ForegroundColor Green
    } else {
        Write-Host ("   ❌ Port {0}: NOT listening" -f $port) -ForegroundColor Red
    }
}

Write-Host "`n✨ Services started! Use 'service-manager.ps1 status' to check." -ForegroundColor Yellow
