$ErrorActionPreference = "Stop"
$manifestPath = ".\fixtures\manifest.generated.json"
if (-not (Test-Path $manifestPath)) { throw "Missing $manifestPath" }
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
foreach ($fixture in $manifest.fixtures) {
    $path = Join-Path ".\fixtures" $fixture.file
    if (-not (Test-Path $path)) { throw "Missing fixture $path" }
    $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $path))
    $sha = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData($bytes)).Replace("-", "").ToLowerInvariant()
    if ($bytes.Length -ne [int]$fixture.bytes) { throw "Length mismatch for $($fixture.file): $($bytes.Length) != $($fixture.bytes)" }
    if ($sha -ne $fixture.sha256) { throw "SHA mismatch for $($fixture.file): $sha != $($fixture.sha256)" }
    if ($bytes.Length -gt 0 -and $bytes[-1] -eq 10) { throw "Fixture has trailing LF: $($fixture.file)" }
    Write-Host "OK $($fixture.file) $sha"
}
