param(
  [string[]]$Slugs
)

$ErrorActionPreference = 'Stop'

if (-not $Slugs -or $Slugs.Count -eq 0) {
  throw 'Please provide one or more skill slugs via -Slugs'
}

$root = 'C:\Users\Administrator\.openclaw\workspaces'
$targets = Get-ChildItem -Path $root -Directory

foreach ($ws in $targets) {
  Write-Host "=== WORKSPACE $($ws.FullName) ==="
  foreach ($slug in $Slugs) {
    Write-Host "INSTALL $slug"
    clawhub install $slug --workdir $ws.FullName --dir skills --no-input
    if ($LASTEXITCODE -ne 0) {
      throw "install failed: $slug @ $($ws.FullName)"
    }
  }
}

Write-Host '=== ALL DONE ==='
