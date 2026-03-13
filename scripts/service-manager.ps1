#!/usr/bin/env powershell
# Service Manager - 管理系统服务（不占用 OpenClaw 后台会话）
# ==============================================================

param(
    [ValidateSet("start", "stop", "status", "restart")]
    [string]$Command = "status"
)

$services = @(
    @{
        Name = "RelayPlane"
        StartScript = "relayplane-proxy"
        StopMethod = "taskkill"
        Port = 3001
    },
    @{
        Name = "ClawSec"
        StartScript = "C:\Users\Administrator\AppData\Local\Programs\Python\Python310\python.exe"
        StartArgs = "C:\Users\Administrator\.openclaw\workspace\skills\clawsec-monitor-main\clawsec-monitor.py start --no-mitm"
        StopMethod = "taskkill"
        Port = 8888
    }
)

function Get-ServiceStatus($svc) {
    # Check port
    $portOpen = netstat -ano | Select-String "LISTEN *:$($svc.Port)" | Measure-Object | Select-Object -ExpandProperty Count
    if ($portOpen -gt 0) {
        return "RUNNING"
    }
    # Check process by name
    $proc = Get-Process | Where-Object { $_.ProcessName -eq ($svc.Name.ToLower() -replace '[^a-z0-9]', '') } | Select-Object -First 1
    if ($proc) {
        return "RUNNING (PID $($proc.Id))"
    }
    return "STOPPED"
}

function Start-Service($svc) {
    if ((Get-ServiceStatus $svc) -like "RUNNING*") {
        Write-Host "$($svc.Name) is already running."
        return
    }

    Write-Host "Starting $($svc.Name)..." -ForegroundColor Yellow
    if ($svc.StartArgs) {
        Start-Process -FilePath $svc.StartScript -ArgumentList $svc.StartArgs -WindowStyle Hidden -PassThru | Out-Null
    } else {
        Start-Process -FilePath $svc.StartScript -WindowStyle Hidden -PassThru | Out-Null
    }
    Start-Sleep -Seconds 2
    Write-Host "$($svc.Name) started. Status: $(Get-ServiceStatus $svc)" -ForegroundColor Green
}

function Stop-Service($svc) {
    $status = Get-ServiceStatus $svc
    if ($status -notlike "RUNNING*") {
        Write-Host "$($svc.Name) is not running."
        return
    }

    Write-Host "Stopping $($svc.Name)..." -ForegroundColor Yellow
    switch ($svc.StopMethod) {
        "taskkill" {
            # Find by port
            $conn = Get-NetTCPConnection -LocalPort $svc.Port -ErrorAction SilentlyContinue
            if ($conn) {
                Stop-Process -Id $conn.OwningProcess -Force
            }
        }
    }
    Start-Sleep -Seconds 1
    Write-Host "$($svc.Name) stopped." -ForegroundColor Green
}

switch ($Command) {
    "start"  { foreach ($svc in $services) { Start-Service $svc } }
    "stop"   { foreach ($svc in $services) { Stop-Service $svc } }
    "restart" { foreach ($svc in $services) { Stop-Service $svc; Start-Service $svc } }
    "status" {
        Write-Host "`n=== Service Status ===" -ForegroundColor Cyan
        foreach ($svc in $services) {
            $status = Get-ServiceStatus $svc
            $color = if ($status -like "RUNNING*") { "Green" } else { "Red" }
            Write-Host "$($svc.Name.PadRight(12)) : $status" -ForegroundColor $color
        }
        Write-Host "`nTo manage: .\service-manager.ps1 [start|stop|restart|status]" -ForegroundColor Gray
    }
}
