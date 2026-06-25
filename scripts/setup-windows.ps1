$ErrorActionPreference = "Stop"
Write-Host "PositionTape Codex Bootstrap — Windows setup"

if (-not (Test-Path ".\AGENTS.md")) {
    throw "Run this script from the repository root."
}

New-Item -ItemType Directory -Force -Path ".\reports\conformance" | Out-Null
New-Item -ItemType Directory -Force -Path ".\tmp" | Out-Null

Write-Host "Checking common toolchains..."
$tools = @("git", "dotnet", "python", "node", "npm", "go", "rustc", "cargo", "java")
foreach ($tool in $tools) {
    $cmd = Get-Command $tool -ErrorAction SilentlyContinue
    if ($cmd) { Write-Host "OK: $tool -> $($cmd.Source)" } else { Write-Host "MISSING: $tool" }
}

Write-Host "Verifying fixtures..."
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-fixtures.ps1

Write-Host "Done. Start Codex with:"
Write-Host "codex --cd . --sandbox workspace-write --ask-for-approval on-request"
Write-Host "or, high-autonomy:"
Write-Host "codex --cd . --sandbox workspace-write --ask-for-approval never --search"
