
## Local execution policy for Windows

When running on native Windows:

- Prefer PowerShell scripts over bash scripts.
- Do not require bash unless WSL or Git Bash is explicitly available.
- If NuGet restore fails with `NU1301`, report it as network/sandbox configuration, not as a source-code failure.
- Prefer no-package conformance runners when package restore is unavailable.
- For xUnit tests, run `dotnet restore` only when network access is available.
- If Python launcher is unavailable or access is denied, skip Python validation and record it in `AGENT_RUN_LOG.md`.
- Never change source code just to work around missing local tools.

## Verification order

1. `dotnet build languages/csharp/src/PositionTape/PositionTape.csproj --configuration Release --no-restore`
2. `dotnet run --project tools/conformance/csharp/PositionTape.Conformance/PositionTape.Conformance.csproj --configuration Release`
3. `dotnet restore` for xUnit projects when network is available.
4. `dotnet test` for xUnit projects after restore succeeds.
5. Optional Python/bash checks only when the tools are available.
