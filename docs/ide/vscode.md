# VS Code

Open `PositionTape.code-workspace` from the repository root.

The workspace includes `docs`, `fixtures`, `tools/conformance`, `integrations`,
agentic assets that are intentionally part of the repository, and each
`languages/<language>` folder. This is a navigation and task workspace, not a
claim that every language toolchain is installed.

## Tasks

The workspace defines relative-path tasks for practical validation:

- `conformance: python fixtures`
- `conformance: csharp no-package`
- `test: csharp xunit`
- `test: python`
- `test: javascript`
- `test: go`
- `test: dart`
- `test: ocaml`
- `test: sqlite`
- `test: prolog`

Some tasks require language tools that may not be installed locally. Check
`SPEC-COMPLIANCE.md` before interpreting a missing executable as a source
failure.

The workspace makes every language folder visible. Buildable-in-workspace
depends on installed terminal tools, not on folder visibility. The current
verified and blocked language lists are summarized in `docs/ide/README.md`.

## Recommended Baseline

```powershell
python .\tools\conformance\run_conformance.py
dotnet run --project .\tools\conformance\csharp\PositionTape.Conformance\PositionTape.Conformance.csproj --configuration Release
dotnet test .\languages\csharp\tests\PositionTape.Tests\PositionTape.Tests.csproj --configuration Release
```

## Workspace Hygiene

The workspace hides common generated folders from search and file watching:
`bin`, `obj`, `build`, `out`, `target`, `.build`, `_build`, `tmp`,
`__pycache__`, `.pytest_cache`, `.toolchain-cache`, `.toolchain-logs`, and
`.diagnostics`.
