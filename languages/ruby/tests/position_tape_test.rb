require "digest"
require "json"
require_relative "../src/position_tape"

def assert_equal(expected, actual, message)
  raise "#{message}: got #{actual.inspect}, want #{expected.inspect}" unless expected == actual
end

assert_equal("", PositionTape.Generate(0), "Generate(0)")
assert_equal("1234567891", PositionTape.Generate(10), "Generate(10)")
assert_equal(101, PositionTape.GenerateMarkerComplete(100).length, "GenerateMarkerComplete(100)")
assert_equal(10_003, PositionTape.GenerateMarkerComplete(10_000).length, "GenerateMarkerComplete(10000)")

expected = PositionTape.Generate(50)
assert_equal(true, PositionTape.Validate(expected, 50).is_valid, "valid result")
assert_equal(18, PositionTape.Validate(expected[0, 17], 50).truncation_point, "truncation point")
assert_equal(4, PositionTape.FindTruncationPoint("123X"), "mismatch point")
assert_equal(13, PositionTape.FindFirstMismatch(expected, "#{expected[0, 12]}X#{expected[13..]}").position, "mismatch")

fragment = PositionTape.Generate(80)[29, 12]
assert_equal("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", PositionTape.HashFragment(""), "sha256 empty")
assert_equal("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", PositionTape.HashFragment("abc"), "sha256 abc")
hash = PositionTape.HashFragment(fragment)
assert_equal(30, PositionTape.Locate(fragment), "Locate")
raise "BuildWindowIndex missing position 30" unless PositionTape.BuildWindowIndex(fragment.length)[hash].include?(30)
raise "LocateByHash missing position 30" unless PositionTape.LocateByHash(hash.upcase, fragment.length).include?(30)

root = File.expand_path("../../..", __dir__)
manifest = JSON.parse(File.read(File.join(root, "fixtures", "manifest.generated.json")))
manifest["fixtures"].each do |fixture|
  raw = File.binread(File.join(root, "fixtures", fixture["file"]))
  assert_equal(fixture["bytes"], raw.bytesize, "#{fixture['file']} bytes")
  assert_equal(fixture["sha256"], Digest::SHA256.hexdigest(raw), "#{fixture['file']} sha256")
  raise "#{fixture['file']} has UTF-8 BOM" if raw.start_with?("\xef\xbb\xbf".b)
  raise "#{fixture['file']} has trailing newline" if raw.end_with?("\n") || raw.end_with?("\r")
end

puts "OK ruby position_tape"
