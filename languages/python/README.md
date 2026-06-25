# PositionTape for Python

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```python
from position_tape import Generate, GenerateMarkerComplete, Validate

exact = Generate(10000)
marker_complete = GenerateMarkerComplete(10000)
validation = Validate(exact, 10000)
```

## Verify

From the repository root:

```powershell
$env:PYTHONPATH = ".\languages\python\src"
python -m unittest discover .\languages\python\tests
```

The tests validate generated output against `fixtures/manifest.generated.json`.
