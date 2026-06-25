$ErrorActionPreference = "Stop"

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command py -ErrorAction SilentlyContinue
}

if (-not $python) {
    throw "Python is required to run tools/conformance/run_conformance.py"
}

if ($python.Name -eq "py.exe" -or $python.Name -eq "py") {
    & $python.Source -3 .\tools\conformance\run_conformance.py
} else {
    & $python.Source .\tools\conformance\run_conformance.py
}
