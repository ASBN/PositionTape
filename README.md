# PositionTape

PositionTape is a deterministic, human-readable diagnostic tape for truncation and payload-integrity testing. It helps identify where text pipelines truncate, mutate, insert, delete, or reorder payload content.

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

GEN-PT-001 provides:

- Official UTF-8 fixtures under `fixtures/`.
- Canonical manifest at `fixtures/manifest.generated.json`.
- Python fixture conformance runner under `tools/conformance/`.
- No-package C# conformance runner under `tools/conformance/csharp/PositionTape.Conformance/`.
- C# reference implementation under `languages/csharp/src/PositionTape/`.
- C# xUnit tests under `languages/csharp/tests/PositionTape.Tests/`.
- GitHub Actions conformance workflow.

## Language Status

Current local validation status is tracked in [SPEC-COMPLIANCE.md](SPEC-COMPLIANCE.md).

| Status | Languages |
|---|---|
| Verified | C, C++, C#, Dart, Go, Java, JavaScript, Julia, Lua, OCaml, Prolog, Python, R, SQLite, Standard ML, VB.NET |
| Implemented but not locally verified | none in this checkpoint |
| Scaffold/guide only | Scratch |
| Blocked by local toolchain | Ada, Assembly, COBOL, Delphi/Object Pascal, Fortran, Kotlin, MATLAB/Octave, Objective-C, Perl, PHP, Ruby, Rust, Swift |

## Verify

Windows PowerShell:

```powershell
.\scripts\verify-fixtures.ps1
dotnet run --project .\tools\conformance\csharp\PositionTape.Conformance\PositionTape.Conformance.csproj --configuration Release
dotnet test .\languages\csharp\tests\PositionTape.Tests\PositionTape.Tests.csproj
```

WSL or Linux:

```bash
./scripts/verify-fixtures.sh
dotnet run --project tools/conformance/csharp/PositionTape.Conformance/PositionTape.Conformance.csproj --configuration Release
dotnet test languages/csharp/tests/PositionTape.Tests/PositionTape.Tests.csproj
```

Direct Python runner:

```bash
python tools/conformance/run_conformance.py
```

## C# Quick Start

```csharp
using Tape = PositionTape.PositionTape;

var exact = Tape.Generate(10000);
var markerComplete = Tape.GenerateMarkerComplete(10000);
var validation = Tape.Validate(exact, expectedLength: 10000);
```

## Repository Layout

- `docs/spec/`: specification.
- `fixtures/`: official fixtures and generated manifest.
- `tools/conformance/`: canonical conformance runner, reference generator, and no-package C# conformance runner.
- `languages/<language>/`: language implementations.
- `integrations/<logger-or-platform>/`: logger integrations.
- `plugins/position-tape-codex/`: local Codex plugin scaffold.

## Agent Safety

Repository-level instructions are in `AGENTS.md`. Codex may create, modify, build, and test files inside this repository, but must not publish packages, push to GitHub, create tags/releases, modify files outside the workspace, or add secrets without explicit approval.
