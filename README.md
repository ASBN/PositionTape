# PositionTape GEN-PT-017 Polish Patch

Incremental patch for the public alpha polish pass.

It creates non-empty `.slnx` files, fixes the conformance workflow, corrects alpha release notes tag language, and moves construction-only patch history out of the repository root when present.

Run from PowerShell:

```powershell
cd C:\Code\PositionTape
.\_patch-gen-pt-017-polish\scripts\apply-gen-pt-017-polish.ps1 -RepoRoot .
```

Then review, validate, commit, and sync branches.

## Open in your IDE

- **Visual Studio**: open `PositionTape.slnx` for a repository showcase map or `PositionTape.DotNet.slnx` for the buildable .NET-focused solution.
- **VS Code**: open `PositionTape.code-workspace` for the polyglot workspace.
- **Terminal/CI**: run the conformance commands documented in `SPEC-COMPLIANCE.md`.
