# PositionTape for vbnet

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```vbnet
Imports PositionTape.PositionTape

Dim exact = Tape.Generate(10000)
Dim markerComplete = Tape.GenerateMarkerComplete(10000)
Dim validation = Tape.Validate(exact, 10000)
```

## Verify

```powershell
dotnet run --project .\languages\vbnet\tests\PositionTape.Tests\PositionTape.Tests.vbproj --configuration Release
```

The tests validate generated output against `fixtures/manifest.generated.json`.
