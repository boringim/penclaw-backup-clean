#!/usr/bin/env powershell
# Install Windows Services for RelayPlane and ClawSec
# ==================================================
# 注意：需要管理员权限运行！

Write-Host "🚀 Installing Windows Services..." -ForegroundColor Cyan

# 检查管理员权限
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Error: This script must be run as Administrator." -ForegroundColor Red
    Write-Host "    Right-click PowerShell and select 'Run as administrator'." -ForegroundColor Yellow
    exit 1
}

# Service 1: RelayPlane
$serviceName1 = "RelayPlaneProxy"
$serviceDesc1 = "RelayPlane AI Model Routing Proxy"
$binaryPath1 = "`"C:\Program Files\nodejs\node.exe`" `"C:\Users\Administrator\AppData\Roaming\npm\node_modules\@relayplane\proxy\bin\proxy.js`" --port 3001"

Write-Host "`n[1/2] Installing RelayPlane service..." -ForegroundColor Yellow
# 删除已存在的同名服务
if (Get-Service -Name $serviceName1 -ErrorAction SilentlyContinue) {
    Write-Host "   Removing existing service..."
    Stop-Service -Name $serviceName1 -Force -ErrorAction SilentlyContinue
    sc.exe delete $serviceName1 | Out-Null
}

# 创建服务
sc.exe create $serviceName1 binPath= $binaryPath1 start= auto DisplayName= "RelayPlane Proxy" | Out-Null
sc.exe description $serviceName1 $serviceDesc1 | Out-Null
Start-Service -Name $serviceName1
Write-Host "   ✅ Service '$serviceName1' created and started." -ForegroundColor Green

# Service 2: ClawSec
$serviceName2 = "ClawSecMonitor"
$serviceDesc2 = "ClawSec Security Monitor (AI Traffic Inspector)"
$binaryPath2 = "`"C:\Users\Administrator\AppData\Local\Programs\Python\Python310\python.exe`" `"C:\Users\Administrator\.openclaw\workspace\skills\clawsec-monitor-main\clawsec-monitor.py`" start --no-mitm"

Write-Host "[2/2] Installing ClawSec service..." -ForegroundColor Yellow
if (Get-Service -Name $serviceName2 -ErrorAction SilentlyContinue) {
    Write-Host "   Removing existing service..."
    Stop-Service -Name $serviceName2 -Force -ErrorAction SilentlyContinue
    sc.exe delete $serviceName2 | Out-Null
}

sc.exe create $serviceName2 binPath= $binaryPath2 start= auto DisplayName= "ClawSec Monitor" | Out-Null
sc.exe description $serviceName2 $serviceDesc2 | Out-Null
Start-Service -Name $serviceName2
Write-Host "   ✅ Service '$serviceName2' created and started." -ForegroundColor Green

# Summary
Write-Host "`n✨ Services installed successfully!" -ForegroundColor Cyan
Write-Host "`nTo check status: Get-Service -Name $serviceName1,$serviceName2"
Write-Host "To stop: Stop-Service -Name <serviceName>"
Write-Host "To remove: sc.exe delete <serviceName>`n"

# Verify ports are listening
Start-Sleep -Seconds 3
Write-Host "📊 Verifying ports..."
$ports = @(3001, 8888)
foreach ($port in $ports) {
    $listening = netstat -ano | Select-String "LISTEN *:$port"
    if ($listening) {
        Write-Host "   ✅ Port $port : listening" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Port $port : NOT listening" -ForegroundColor Red
    }
}
