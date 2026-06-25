# PositionTape for julia

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```julia
include("src/PositionTape.jl")
using .PositionTape

exact = Generate(10000)
marker_complete = GenerateMarkerComplete(10000)
validation = Validate(exact, 10000)
```

## Verify

```powershell
julia .\languages\julia\tests\position_tape_tests.jl
```

The tests validate generated output against `fixtures/manifest.generated.json`.
