require_relative "../src/position_tape"

exact = PositionTape.Generate(100)
marker_complete = PositionTape.GenerateMarkerComplete(1000)
validation = PositionTape.Validate(exact, 100)

puts exact
puts marker_complete.length
puts validation.is_valid
