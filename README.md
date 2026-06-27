# PositionTape

[![core conformance / master](https://github.com/ASBN/PositionTape/actions/workflows/conformance.yml/badge.svg?branch=master)](https://github.com/ASBN/PositionTape/actions/workflows/conformance.yml?query=branch%3Amaster)
[![polyglot verified / master](https://github.com/ASBN/PositionTape/actions/workflows/polyglot-verified.yml/badge.svg?branch=master)](https://github.com/ASBN/PositionTape/actions/workflows/polyglot-verified.yml?query=branch%3Amaster)
[![polyglot verified / dev](https://github.com/ASBN/PositionTape/actions/workflows/polyglot-verified.yml/badge.svg?branch=dev)](https://github.com/ASBN/PositionTape/actions/workflows/polyglot-verified.yml?query=branch%3Adev)
[![tag](https://img.shields.io/github/v/tag/ASBN/PositionTape?label=tag)](https://github.com/ASBN/PositionTape/tags)
[![license](https://img.shields.io/github/license/ASBN/PositionTape)](https://github.com/ASBN/PositionTape/blob/master/LICENSE)
[![status](https://img.shields.io/badge/status-alpha-orange)](https://github.com/ASBN/PositionTape/blob/master/docs/releases/alpha.md)
[![languages](https://img.shields.io/github/languages/count/ASBN/PositionTape)](https://github.com/ASBN/PositionTape/tree/master/languages)

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

See [docs/spec/position-tape-spec.md](docs/spec/position-tape-spec.md) for the
full specification. Level 3 hash-window implementations must also follow the
[SHA-256 provider policy](docs/spec/hash-provider-policy.md).

## CI Status

PositionTape separates stable contract validation from broader language monitoring:

- **Core conformance** is the required, fast baseline. It checks fixtures, the no-package C# conformance runner, and C# tests.
- **Polyglot verified** checks the currently verified portable language implementations in GitHub Actions.
- **Polyglot experimental** attempts blocked or heavier toolchains as monitoring only. It is intentionally allowed to fail.

See [docs/ci/README.md](docs/ci/README.md) for the CI policy.

## Current Foundation

The alpha foundation provides:

- Official UTF-8 fixtures under `fixtures/`.
- Canonical manifest at `fixtures/manifest.generated.json`.
- Python fixture conformance runner under `tools/conformance/`.
- Shared SHA-256 vectors at `fixtures/sha256-vectors.json`.
- No-package C# conformance runner under `tools/conformance/csharp/PositionTape.Conformance/`.
- C# reference implementation under `languages/csharp/src/PositionTape/`.
- C# xUnit tests under `languages/csharp/tests/PositionTape.Tests/`.
- GitHub Actions core conformance and polyglot monitoring workflows.

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

| Category | Languages |
|---|---|
| Level 3 verified | Ada, C, C++, C#, Dart, Delphi/Object Pascal, Fortran, Go, Java, JavaScript, Julia, Kotlin, Lua, OCaml, PHP, Prolog, Python, R, Ruby, Standard ML, VB.NET |
| Level 3 verified with extension/hybrid provider | SQLite, when the repo-local SHA-256 loadable extension is built and loaded |
| Level 3 source-only | MATLAB/Octave, Perl, Rust, Swift |
| Level 2 source-only / blocked on Windows | Objective-C |
| Level 1 / scaffold | Assembly, COBOL, Scratch |
| CI verified | Core baseline plus portable polyglot checks in `polyglot-verified.yml`; broader experimental checks are monitoring only |

Blocker notes:

- Blocked or source-only languages have source and tests, but their validation command did not complete in the latest local checkpoint because the local runtime path is incomplete, the Windows toolchain cannot link that language, or the exact SHA-256 hash-window path is too slow or unavailable.
- MATLAB/Octave is installed locally, but the full hash-window test is slow/unstable in Octave 11.3.0 on this Windows path; the exact blocking section is `BuildWindowIndex(length(fragment))` / `LocateByHash`.
- SQLite is locally verified at Level 3 when its repo-local `sha256(text)` loadable extension is built and loaded; SQLite SHA3 is still not used as a substitute.
- Assembly and COBOL remain Level 1. COBOL now has a verified call into the shared C SHA-256 provider for required ASCII vectors, and Assembly has a verified minimal Win64 NASM-to-C ABI probe, but neither exposes the full Level 3 hash-window API.
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
