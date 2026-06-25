# Codex Windows verification notes

Use this note when Codex runs inside native Windows PowerShell.

## Known environment differences

- Bash may be unavailable unless WSL or Git Bash is installed and in `PATH`.
- Python may be installed as `py`, `python`, or may be blocked by Windows app execution aliases.
- `dotnet test` requires NuGet restore unless all packages are already available locally.
- `NU1301` usually means the restore process cannot reach NuGet or the sandbox blocked network access.

## Preferred behavior

- Prefer `scripts/*.ps1` over `scripts/*.sh` on Windows.
- If NuGet restore is blocked, report it as an environment/sandbox issue.
- Continue with no-package conformance runners when available.
- Record exact commands and results in `AGENT_RUN_LOG.md`.
