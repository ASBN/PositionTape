import Foundation
import PositionTape

func assert(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
}

assert(PositionTape.Generate(0) == "", "zero length")
assert(PositionTape.Generate(11) == "12345678911", "basic generation")
assert(PositionTape.Generate(100).count == 100, "exact boundary")
assert(PositionTape.GenerateMarkerComplete(100).count == 101, "marker complete 100")
assert(PositionTape.GenerateMarkerComplete(10_000).count == 10_003, "marker complete 10000")

let valid = PositionTape.Validate(PositionTape.Generate(250), 250)
assert(valid.isValid, "valid tape")

let truncated = PositionTape.Validate(PositionTape.Generate(40), 50)
assert(!truncated.isValid, "truncated invalid")
assert(truncated.truncationPoint == 41, "truncation point")

var mutated = Array(PositionTape.Generate(60))
mutated[19] = "X"
let mismatch = PositionTape.FindFirstMismatch(PositionTape.Generate(60), String(mutated))
assert(mismatch?.position == 20, "first mismatch")

assert(PositionTape.FindTruncationPoint(PositionTape.Generate(75)) == 76, "find truncation")
assert(PositionTape.Locate("9910") == 99, "locate fragment")

let fragment = String(Array(PositionTape.Generate(600))[198..<214])
let positions = PositionTape.LocateByHash(PositionTape.HashFragment(fragment), fragment.count)
assert(positions.contains(199), "locate by hash")

print("OK swift")
