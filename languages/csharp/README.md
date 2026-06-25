# PositionTape for C#

Status: reference implementation.

Target conformance level: Level 3.

## Projects

- `src/PositionTape/PositionTape.csproj`: dependency-free core library.
- `tests/PositionTape.Tests/PositionTape.Tests.csproj`: xUnit fixture and API tests.
- `../../tools/conformance/csharp/PositionTape.Conformance/`: no-package conformance runner for restricted local environments.

## Public API

The reference implementation exposes:

- `PositionTape.Generate(length)`
- `PositionTape.GenerateMarkerComplete(length)`
- `PositionTape.Locate(fragment)`
- `PositionTape.Validate(receivedText, expectedLength)`
- `PositionTape.FindTruncationPoint(receivedText)`
- `PositionTape.FindFirstMismatch(expected, received)`
- `PositionTape.BuildWindowIndex(windowSize)`
- `PositionTape.LocateByHash(fragmentHash, windowSize)`

Supporting helpers:

- `PositionTape.HashFragment(fragment)`
- `PositionTape.GetMarkerCompleteLength(length)`

## Verify

```powershell
dotnet run --project .\tools\conformance\csharp\PositionTape.Conformance\PositionTape.Conformance.csproj --configuration Release
dotnet test .\languages\csharp\tests\PositionTape.Tests\PositionTape.Tests.csproj
```
