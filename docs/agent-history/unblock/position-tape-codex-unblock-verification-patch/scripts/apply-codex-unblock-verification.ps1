param(
    [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$patchRoot = Split-Path -Parent $PSScriptRoot

Write-Host "Applying PositionTape Codex unblock verification patch to $RepoRoot"

$filesToCopy = @(
    "codex/config/high-autonomy-with-network.toml",
    "codex/config/position-tape.high-autonomy-network.config.toml",
    "codex/prompts/01-unblock-verification.md",
    "docs/agentic-plan/CODEX_WINDOWS_VERIFICATION_NOTES.md"
)

foreach ($rel in $filesToCopy) {
    $src = Join-Path $patchRoot $rel
    $dst = Join-Path $RepoRoot $rel
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
    Copy-Item -Force $src $dst
    Write-Host "Copied $rel"
}

$agentsPath = Join-Path $RepoRoot "AGENTS.md"
$addendumPath = Join-Path $patchRoot "AGENTS.codex-local-addendum.md"
$marker = "## Local execution policy for Windows"

if (Test-Path $agentsPath) {
    $agents = Get-Content $agentsPath -Raw
    if ($agents -notmatch [regex]::Escape($marker)) {
        Add-Content -Path $agentsPath -Value "`n"
        Add-Content -Path $agentsPath -Value (Get-Content $addendumPath -Raw)
        Write-Host "Appended Windows execution policy to AGENTS.md"
    } else {
        Write-Host "AGENTS.md already contains Windows execution policy; skipped append"
    }
} else {
    Copy-Item -Force $addendumPath $agentsPath
    Write-Host "Created AGENTS.md from addendum"
}

Write-Host "Patch applied. Start Codex with:"
Write-Host 'codex --cd . --sandbox workspace-write --ask-for-approval never -c sandbox_workspace_write.network_access=true --search'
