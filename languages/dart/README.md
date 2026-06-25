# PositionTape for dart

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```dart
import 'src/position_tape.dart' as pt;

final exact = pt.Generate(10000);
final markerComplete = pt.GenerateMarkerComplete(10000);
final validation = pt.Validate(exact, 10000);
```

## Verify

```powershell
dart run .\languages\dart\tests\position_tape_test.dart
```

The tests validate generated output against `fixtures/manifest.generated.json`.
