# PositionTape for standard-ml

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```sml
use "languages/standard-ml/src/position_tape.sml";

val exact = PositionTape.generate 10000;
val markerComplete = PositionTape.generateMarkerComplete 10000;
val validation = PositionTape.validate (exact, 10000);
```

## Verify

```powershell
sml < .\languages\standard-ml\tests\position_tape_tests.sml
```
