# GitHub Codespaces And Dev Containers

The repository includes `.devcontainer/devcontainer.json` for a minimal
verified stack:

- .NET SDK through the base image
- Python
- Node.js
- Go
- Java 21 without Maven or Gradle

The container intentionally does not install every PositionTape language
toolchain. Full Genkidama-style coverage across Ada, Assembly, COBOL, Delphi,
Fortran, MATLAB/Octave, Objective-C, Perl, PHP, Ruby, Rust, Swift, and other
ecosystems is too heavy for the default Codespaces path and would overstate
alpha readiness.

## First Checks

```bash
python tools/conformance/run_conformance.py
dotnet run --project tools/conformance/csharp/PositionTape.Conformance/PositionTape.Conformance.csproj --configuration Release
dotnet test languages/csharp/tests/PositionTape.Tests/PositionTape.Tests.csproj --configuration Release
node languages/javascript/tests/position-tape.test.js
(cd languages/go && go test ./...)
```

Use `SPEC-COMPLIANCE.md` for the current validation matrix. If a language
toolchain is absent from the container, that is expected unless the docs say the
minimal stack includes it.

## Artifact Hygiene

Before committing from Codespaces, check:

```bash
git status --short
git ls-files -o --exclude-standard
```

Do not commit generated binaries, caches, logs, local diagnostics, `bin/`,
`obj/`, `build/`, `out/`, `target/`, `.build/`, `_build/`, `tmp/`, or
`__pycache__/`.
