# Rider And JetBrains IDEs

Use `PositionTape.DotNet.slnx` for .NET work in Rider. It contains only real
SDK-style C# and VB.NET projects that should build through .NET tooling.

`PositionTape.slnx` is also available as the root showcase solution. It has the
same real .NET project set and should not be read as a promise that Rider can
build every language folder.

For non-.NET languages, use Rider's filesystem view or the matching JetBrains
IDE/plugin where available. Follow `SPEC-COMPLIANCE.md` for each language's
actual validation command and current blocker status.

In this alpha, Rider/.NET solution build support is limited to the C# and
VB.NET projects. Other languages are documented and browsable only unless their
own terminal toolchain is installed.

## Practical Commands

```powershell
dotnet build .\PositionTape.DotNet.slnx --configuration Release
dotnet test .\languages\csharp\tests\PositionTape.Tests\PositionTape.Tests.csproj --configuration Release
python .\tools\conformance\run_conformance.py
dotnet run --project .\tools\conformance\csharp\PositionTape.Conformance\PositionTape.Conformance.csproj --configuration Release
```

Do not commit `.idea/`, local run configurations, generated binaries, package
caches, `bin/`, `obj/`, `target/`, `build/`, or toolchain logs.
