# Goal: Unblock verification

Read `AGENTS.md` and `AGENT_RUN_LOG.md` first.

Current known blockers from the previous checkpoint:

- xUnit `dotnet test` restore failed with `NU1301` because NuGet network access was denied.
- Python launcher access was denied.
- Bash was unavailable on native Windows.

Continue from the previous checkpoint.

## Execution rules

1. Confirm current working directory and list root files.
2. Inspect the current Codex sandbox/network situation if possible.
3. Run `dotnet restore` for the C# solution or C# test projects if network is available.
4. Run `dotnet test` for C# xUnit tests.
5. Run the no-package C# conformance runner.
6. Prefer PowerShell scripts over bash scripts on native Windows.
7. Do not require bash unless WSL/Git Bash is explicitly available.
8. Do not require Python unless it is available; if blocked, record it and continue with .NET verification.
9. Do not change source code just to work around missing local tools.
10. Update `AGENT_RUN_LOG.md` with exact commands, results, blockers, and next actions.

## Boundaries

- Do not publish packages.
- Do not push to GitHub.
- Do not modify files outside this repository.
- Do not commit unless explicitly asked.
