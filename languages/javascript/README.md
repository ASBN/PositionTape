# PositionTape for JavaScript

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```javascript
const { Generate, GenerateMarkerComplete, Validate } = require("./src/position-tape");

const exact = Generate(10000);
const markerComplete = GenerateMarkerComplete(10000);
const validation = Validate(exact, 10000);
```

## Verify

From the repository root:

```powershell
node .\languages\javascript\tests\position-tape.test.js
```

The tests validate generated output against `fixtures/manifest.generated.json`.
