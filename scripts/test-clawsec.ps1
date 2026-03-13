#!/usr/bin/env powershell
# Quick test for ClawSec Monitor (Windows friendly)
# Checks if Python deps are installed and can import the module

Write-Host "=== ClawSec Preflight Check ===" -ForegroundColor Cyan

# Check Python
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Host "❌ Python not found. Install Python 3.10+ first." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Python found: $($python.Source)"

# Check cryptography
try {
    python -c "import cryptography; print('cryptography version:', cryptography.__version__)" 2>&1
    Write-Host "✅ cryptography module OK" -ForegroundColor Green
} catch {
    Write-Host "❌ cryptography module missing. Run: pip install cryptography" -ForegroundColor Red
    exit 1
}

# Check if monitor script exists
$monitor = "C:\Users\Administrator\.openclaw\workspace\skills\clawsec-monitor-main\clawsec-monitor.py"
if (Test-Path $monitor) {
    Write-Host "✅ Monitor script found: $monitor" -ForegroundColor Green
} else {
    Write-Host "❌ Monitor script not found. Re-download from GitHub." -ForegroundColor Red
    exit 1
}

Write-Host "`n🚀 Ready! Start with:" -ForegroundColor Yellow
Write-Host "  cd C:\Users\Administrator\.openclaw\workspace\skills\clawsec-monitor-main"
Write-Host "  python clawsec-monitor.py start --no-mitm"
Write-Host "`nThen check: python clawsec-monitor.py status"
