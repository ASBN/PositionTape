# PositionTape for ruby

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```ruby
require_relative "src/position_tape"

exact = PositionTape.Generate(10000)
marker_complete = PositionTape.GenerateMarkerComplete(10000)
validation = PositionTape.Validate(exact, 10000)
```

## Verify

```powershell
ruby .\languages\ruby\tests\position_tape_test.rb
```
