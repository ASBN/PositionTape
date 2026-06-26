# Visual Studio

## Solution Files

`PositionTape.slnx` is the root Visual Studio showcase solution.

It includes the real .NET projects that Visual Studio can load cleanly:

- `languages/csharp/src/PositionTape/PositionTape.csproj`
- `languages/csharp/tests/PositionTape.Tests/PositionTape.Tests.csproj`
- `tools/conformance/csharp/PositionTape.Conformance/PositionTape.Conformance.csproj`
- `languages/vbnet/src/PositionTape/PositionTape.vbproj`
- `languages/vbnet/tests/PositionTape.Tests/PositionTape.Tests.vbproj`

`PositionTape.DotNet.slnx` is the build-focused .NET solution with the same real project set. Use it when running `dotnet build` or `dotnet test` from .NET tooling.

## What Visual Studio Does Not Promise

The repository contains many non-.NET language folders. They are not added as fake projects because `.slnx` should not imply that Visual Studio can build all languages.

Browse those folders from the filesystem, VS Code workspace, or the language-specific tooling documented in `SPEC-COMPLIANCE.md`.

Documented-only in Visual Studio means all non-.NET language folders. Their current terminal validation status is listed in `docs/ide/README.md` and `SPEC-COMPLIANCE.md`.

## Common Commands

```powershell
dotnet build .\PositionTape.DotNet.slnx --configuration Release

dotnet test .\languages\csharp\tests\PositionTape.Tests\PositionTape.Tests.csproj --configuration Release

dotnet run --project .\tools\conformance\csharp\PositionTape.Conformance\PositionTape.Conformance.csproj --configuration Release

python .\tools\conformance\run_conformance.py
```

If restore fails with `NU1301`, treat it as network or package-source access, not as a source-code failure.

## Generated Artifacts

Do not commit `bin/`, `obj/`, `TestResults/`, local user files, toolchain logs, or generated binaries. The root `.gitignore` excludes these artifacts.
