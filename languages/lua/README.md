# PositionTape for lua

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```lua
local pt = require("position_tape")

local exact = pt.Generate(10000)
local marker_complete = pt.GenerateMarkerComplete(10000)
local validation = pt.Validate(exact, 10000)
```

## Verify

From the repository root:

```powershell
lua .\languages\lua\tests\position_tape_tests.lua
```

The tests validate generated output against `fixtures/manifest.generated.json`.
