include("../src/PositionTape.jl")

using .PositionTape
using SHA
using Test

@test Generate(0) == ""
@test Generate(10) == "1234567891"
@test Generate(20) == "12345678911234567892"
@test length(Generate(100)) == 100

@test GenerateMarkerComplete(99) == Generate(99)
@test GenerateMarkerComplete(100) == Generate(101)
@test length(GenerateMarkerComplete(1000)) == 1002
@test length(GenerateMarkerComplete(10000)) == 10003

expected = Generate(50)
@test Validate(expected, 50).is_valid
@test Validate(expected[1:17], 50).truncation_point == 18
@test FindTruncationPoint("123X") == 4
@test FindFirstMismatch(expected, expected[1:12] * "X" * expected[14:end]).position == 13

fragment = Generate(80)[30:41]
hash = HashFragment(fragment)
@test Locate(fragment) == 30
@test 30 in BuildWindowIndex(length(fragment))[hash]
@test 30 in LocateByHash(uppercase(hash), length(fragment))

root = normpath(joinpath(@__DIR__, "..", "..", ".."))
manifest = read(joinpath(root, "fixtures", "manifest.generated.json"), String)
fixture_pattern = Regex("\"file\":\\s*\"([^\"]+)\".*?\"bytes\":\\s*(\\d+).*?\"sha256\":\\s*\"([^\"]+)\"", "s")
for fixture_match in eachmatch(fixture_pattern, manifest)
    file, bytes, sha = fixture_match.captures
    raw = read(joinpath(root, "fixtures", file))
    @test length(raw) == parse(Int, bytes)
    @test bytes2hex(sha256(raw)) == sha
    @test !(length(raw) >= 3 && raw[1:3] == UInt8[0xef, 0xbb, 0xbf])
    @test (isempty(raw) || (raw[end] != UInt8('\n') && raw[end] != UInt8('\r')))

    text = String(raw)
    exact = match(r"^position_tape_(\d+)\.txt$", file)
    complete = match(r"^position_tape_(\d+)_marker_complete\.txt$", file)
    generated = exact !== nothing ? Generate(parse(Int, exact.captures[1])) : GenerateMarkerComplete(parse(Int, complete.captures[1]))
    @test text == generated
end

println("OK julia position_tape")
