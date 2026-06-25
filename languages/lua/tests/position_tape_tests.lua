package.path = "languages/lua/src/?.lua;" .. package.path

local pt = require("position_tape")

local function assert_equal(actual, expected, message)
  if actual ~= expected then
    error((message or "assertion failed") .. ": got " .. tostring(actual) .. ", want " .. tostring(expected), 2)
  end
end

local function contains(values, expected)
  for _, value in ipairs(values) do
    if value == expected then
      return true
    end
  end
  return false
end

assert_equal(pt.Generate(0), "", "Generate(0)")
assert_equal(pt.Generate(10), "1234567891", "Generate(10)")
assert_equal(pt.Generate(20), "12345678911234567892", "Generate(20)")
assert_equal(#pt.Generate(100), 100, "Generate(100) length")

assert_equal(pt.GenerateMarkerComplete(99), pt.Generate(99), "marker complete 99")
assert_equal(pt.GenerateMarkerComplete(100), pt.Generate(101), "marker complete 100")
assert_equal(#pt.GenerateMarkerComplete(1000), 1002, "marker complete 1000")
assert_equal(#pt.GenerateMarkerComplete(10000), 10003, "marker complete 10000")

local expected = pt.Generate(50)
local valid = pt.Validate(expected, 50)
assert_equal(valid.is_valid, true, "valid result")

local truncated = pt.Validate(expected:sub(1, 17), 50)
assert_equal(truncated.is_valid, false, "truncated result")
assert_equal(truncated.truncation_point, 18, "truncated point")
assert_equal(truncated.first_mismatch.position, 18, "truncated mismatch")

local mutated = expected:sub(1, 12) .. "X" .. expected:sub(14)
local mismatch = pt.FindFirstMismatch(expected, mutated)
assert_equal(mismatch.position, 13, "mismatch position")
assert_equal(mismatch.expected, expected:sub(13, 13), "mismatch expected")
assert_equal(mismatch.received, "X", "mismatch received")
assert_equal(pt.FindTruncationPoint("123X"), 4, "truncation mismatch point")

local fragment = pt.Generate(80):sub(30, 41)
assert_equal(pt.Locate(fragment), 30, "Locate")
local hash = pt.HashFragment(fragment)
local index = pt.BuildWindowIndex(#fragment)
if not contains(index[hash], 30) then
  error("BuildWindowIndex missing position 30")
end
if not contains(pt.LocateByHash(hash:upper(), #fragment), 30) then
  error("LocateByHash missing position 30")
end

local manifest = assert(io.open("fixtures/manifest.generated.json", "rb")):read("*a")
for entry in manifest:gmatch('{%s*"file":%s*"([^"]+)",%s*"bytes":%s*(%d+),%s*"sha256":%s*"([^"]+)"') do
end
for file, bytes, sha in manifest:gmatch('"file":%s*"([^"]+)".-"bytes":%s*(%d+).-"sha256":%s*"([^"]+)"') do
  local handle = assert(io.open("fixtures/" .. file, "rb"))
  local raw = handle:read("*a")
  handle:close()

  assert_equal(#raw, tonumber(bytes), file .. " bytes")
  assert_equal(pt.HashFragment(raw), sha, file .. " sha256")
  if raw:sub(1, 3) == "\239\187\191" then
    error(file .. " has UTF-8 BOM")
  end
  local last = raw:sub(-1)
  if last == "\n" or last == "\r" then
    error(file .. " has trailing newline")
  end

  local exact_length = file:match("^position_tape_(%d+)%.txt$")
  local complete_length = file:match("^position_tape_(%d+)_marker_complete%.txt$")
  local generated = exact_length and pt.Generate(tonumber(exact_length)) or pt.GenerateMarkerComplete(tonumber(complete_length))
  assert_equal(raw, generated, file .. " generated")
end

print("OK lua position_tape")
