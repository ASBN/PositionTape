# PositionTape

PositionTape is a deterministic, human-readable diagnostic tape for truncation and payload-integrity testing. It helps identify where text pipelines truncate, mutate, insert, delete, or reorder payload content.

Alpha status: this repository is at the first public GitHub alpha source snapshot, tagged `v0.1.0-alpha.1`. The core algorithm and fixture manifest are stable, but several language folders are experimental or blocked by local toolchain availability.

Do not treat every language as release-grade yet; see [SPEC-COMPLIANCE.md](SPEC-COMPLIANCE.md).

The open source repository owns the algorithm, fixtures, conformance tests, language packages, and basic logger integrations. Commercial ASBN inspector products live outside this repository.

## Algorithm

Positions are 1-indexed.

- Positions not divisible by 10 emit their last digit.
- Positions divisible by 10 emit the decimal text of `position / 10`.
- Multi-character markers occupy consecutive output positions and advance the cursor by marker length.
- Exact-length generation returns exactly the requested length, truncating a marker at the boundary when needed.
- Marker-complete generation extends only when the requested boundary cuts through a marker.

See [docs/spec/position-tape-spec.md](docs/spec/position-tape-spec.md) for the full specification.

## Current Foundation

The alpha foundation provides:

- Official UTF-8 fixtures under `fixtures/`.
- Canonical manifest at `fixtures/manifest.generated.json`.
- Python fixture conformance runner under `tools/conformance/`.
- No-package C# conformance runner under `tools/conformance/csharp/PositionTape.Conformance/`.
- C# reference implementation under `languages/csharp/src/PositionTape/`.
- C# xUnit tests under `languages/csharp/tests/PositionTape.Tests/`.
- GitHub Actions conformance workflow for fixture and C# baseline checks.

## Install / Use

No packages are published for this alpha yet. Use the repository source directly.

### C# from the repository

```powershell
dotnet build .\languages\csharp\src\PositionTape\PositionTape.csproj --configuration Release
```

```csharp
using Tape = PositionTape.PositionTape;

var exact = Tape.Generate(10000);
var markerComplete = Tape.GenerateMarkerComplete(10000);
var validation = Tape.Validate(exact, expectedLength: 10000);
```

### Python from the repository

```powershell
$env:PYTHONPATH = ".\languages\python\src"
python -c "from position_tape import Generate, GenerateMarkerComplete, Validate; text = Generate(10000); print(len(text), len(GenerateMarkerComplete(10000)), Validate(text, 10000).ok)"
```

## Open In Your IDE

- Visual Studio: open `PositionTape.slnx` for the repository showcase or `PositionTape.DotNet.slnx` for .NET-focused build/test work.
- VS Code: open `PositionTape.code-workspace` for a polyglot workspace with docs, fixtures, conformance tools, integrations, agentic assets, and each language folder.
- Rider / JetBrains: use `PositionTape.DotNet.slnx` for .NET work and see [docs/ide/rider.md](docs/ide/rider.md) for guidance.
- GitHub Codespaces / dev containers: see [docs/ide/codespaces.md](docs/ide/codespaces.md) for the minimal verified stack.
- Terminal baseline: run the conformance commands below.

IDE visibility is not a conformance claim. Use [SPEC-COMPLIANCE.md](SPEC-COMPLIANCE.md) for the current language validation matrix and blocked toolchains.

## Language Status

Current local validation status is tracked in [SPEC-COMPLIANCE.md](SPEC-COMPLIANCE.md).

| Status | Languages |
|---|---|
| Verified | C, C++, C#, Dart, Go, Java, JavaScript, Julia, Lua, OCaml, Prolog, Python, R, SQLite, Standard ML, VB.NET |
| Scaffold/guide only | Scratch |
| Blocked by local toolchain | Ada, Assembly, COBOL, Delphi/Object Pascal, Fortran, Kotlin, MATLAB/Octave, Objective-C, Perl, PHP, Ruby, Rust, Swift |

Blocker notes:

- Blocked languages have source and tests, but their validation command did not run in the latest local checkpoint because the required compiler/runtime was absent or the local Windows toolchain could not link.
- Some verified languages validate API behavior and marker boundaries but do not yet read every official fixture file directly. The exact status is in [SPEC-COMPLIANCE.md](SPEC-COMPLIANCE.md).
- Scratch is a text guide only; no `.sb3` project is generated in this alpha.

## Verify

### Windows PowerShell

```powershell
.\scripts\verify-fixtures.ps1

dotnet run --project .\tools\conformance\csharp\PositionTape.Conformance\PositionTape.Conformance.csproj --configuration Release

dotnet test .\languages\csharp\tests\PositionTape.Tests\PositionTape.Tests.csproj --configuration Release
```

### WSL or Linux

```bash
./scripts/verify-fixtures.sh

dotnet run --project tools/conformance/csharp/PositionTape.Conformance/PositionTape.Conformance.csproj --configuration Release

dotnet test languages/csharp/tests/PositionTape.Tests/PositionTape.Tests.csproj --configuration Release
```

### Direct Python runner

```bash
python tools/conformance/run_conformance.py
```

## Repository Layout

- `docs/spec/`: specification.
- `fixtures/`: official fixtures and generated manifest.
- `tools/conformance/`: canonical conformance runner, reference generator, and no-package C# conformance runner.
- `languages/`: language implementations.
- `integrations/`: logger integrations.
- `plugins/position-tape-codex/`: local Codex plugin scaffold.

## Release Notes

See [docs/releases/alpha.md](docs/releases/alpha.md) for the current alpha release notes.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security

See [SECURITY.md](SECURITY.md).

## Agent Safety

Repository-level instructions are in [AGENTS.md](AGENTS.md). Codex may create, modify, build, and test files inside this repository, but must not publish packages, push to GitHub, create tags/releases, modify files outside the workspace, or add secrets without explicit approval.

## License

Apache-2.0. See [LICENSE](LICENSE).
