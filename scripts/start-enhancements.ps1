#!/usr/bin/env powershell
# OpenClaw Enhanced Security & Cost Optimization Setup
# Starts RelayPlane proxy and ClawSec monitor

Write-Host "🚀 Starting OpenClaw Enhancement Suite..." -ForegroundColor Green

# 1. Start RelayPlane Proxy (cost optimization)
Write-Host "`n[1/2] Starting RelayPlane proxy on port 3001..." -ForegroundColor Yellow
Start-Process relayplane-proxy -WindowStyle Hidden
Start-Sleep -Seconds 2

# 2. Start ClawSec Monitor (security)
Write-Host "[2/2] Starting ClawSec monitor on port 8888..." -ForegroundColor Yellow
$clawsecDir = "C:\Users\Administrator\.openclaw\workspace\skills\clawsec"
Start-Process python3 -ArgumentList "$clawsecDir\clawsec-monitor.py start" -WindowStyle Hidden
Start-Sleep -Seconds 2

# 3. Set environment variables for current session
Write-Host "`n✅ Services started! To use them in your OpenClaw session, run:" -ForegroundColor Green
Write-Host "`nexport ANTHROPIC_BASE_URL=http://localhost:3001" -ForegroundColor Cyan
Write-Host "export OPENAI_BASE_URL=http://localhost:3001" -ForegroundColor Cyan
Write-Host "export HTTP_PROXY=http://127.0.0.1:8888" -ForegroundColor Cyan
Write-Host "export HTTPS_PROXY=http://127.0.0.1:8888" -ForegroundColor Cyan
Write-Host "`nOr add these to your shell profile (~/.bashrc, ~/.zshrc, or PowerShell profile)." -ForegroundColor Gray

# Check status
Write-Host "`n📊 Status Check:" -ForegroundColor Green
Write-Host "RelayPlane: http://localhost:3001 (auto-routes to cheapest model)" -ForegroundColor Gray
Write-Host "ClawSec:    http://localhost:8888 (security monitor)" -ForegroundColor Gray

Write-Host "`n💡 Commands:" -ForegroundColor Green
Write-Host "  relayplane-proxy stats    - View cost savings" -ForegroundColor Gray
Write-Host "  relayplane-proxy dashboard - Open dashboard" -ForegroundColor Gray
Write-Host "  python3 $clawsecDir\clawsec-monitor.py status - Check security threats" -ForegroundColor Gray
Write-Host "  python3 $clawsecDir\clawsec-monitor.py threats - View recent threats" -ForegroundColor Gray

Write-Host "`n⚠️  Note: For HTTPS decryption, install ClawSec CA cert:" -ForegroundColor Yellow
Write-Host "  sudo cp /tmp/clawsec/ca.crt /usr/local/share/ca-certificates/clawsec.crt && sudo update-ca-certificates" -ForegroundColor Gray
