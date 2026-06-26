param(
    [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$patchRoot = Split-Path -Parent $PSScriptRoot

Write-Host "Applying PositionTape Codex iteration runner patch to $RepoRoot"

$filesToCopy = @(
    "codex/prompts/99-run-all-iterations.md",
    "codex/prompts/98-review-and-tighten.md",
    "docs/agentic-plan/CODEX_ITERATION_RUNBOOK.md"
)

foreach ($rel in $filesToCopy) {
    $src = Join-Path $patchRoot $rel
    $dst = Join-Path $RepoRoot $rel
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
    Copy-Item -Force $src $dst
    Write-Host "Copied $rel"
}

$agentsPath = Join-Path $RepoRoot "AGENTS.md"
$addendumPath = Join-Path $patchRoot "AGENTS.agentic-iteration-addendum.md"
$marker = "## Agentic iteration policy"

if (Test-Path $agentsPath) {
    $agents = Get-Content $agentsPath -Raw
    if ($agents -notmatch [regex]::Escape($marker)) {
        Add-Content -Path $agentsPath -Value "`n"
        Add-Content -Path $agentsPath -Value (Get-Content $addendumPath -Raw)
        Write-Host "Appended agentic iteration policy to AGENTS.md"
    } else {
        Write-Host "AGENTS.md already contains agentic iteration policy; skipped append"
    }
} else {
    Copy-Item -Force $addendumPath $agentsPath
    Write-Host "Created AGENTS.md from addendum"
}

Write-Host "Patch applied. Paste the /goal from codex/prompts/99-run-all-iterations.md or from the assistant response."
