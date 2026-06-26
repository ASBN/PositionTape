# GEN-PT-018 Flat Patch

Purpose: surgical public-alpha polish using only plain files.

This patch rewrites previously minified or empty public-facing files:

- `PositionTape.slnx`
- `PositionTape.DotNet.slnx`
- `.github/workflows/conformance.yml`
- `README.md`
- `docs/releases/alpha.md`
- `docs/ide/README.md`
- `docs/ide/visual-studio.md`
- `docs/ide/vscode.md`
- `docs/ide/rider.md`
- `docs/ide/codespaces.md`

No scripts, binaries, generated build outputs, tags, releases, package publishing steps, or algorithm changes are included.

Recommended validation after overlay:

```powershell
[xml](Get-Content .\PositionTape.slnx -Raw) | Out-Null
[xml](Get-Content .\PositionTape.DotNet.slnx -Raw) | Out-Null

python .\tools\conformance\run_conformance.py

dotnet run --project .\tools\conformance\csharp\PositionTape.Conformance\PositionTape.Conformance.csproj --configuration Release

git status --short
```
