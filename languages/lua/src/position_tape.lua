local M = {}

M.DEFAULT_SEARCH_LENGTH = 100003
local index_cache = {}

local function assert_non_negative_integer(value, name)
  if type(value) ~= "number" or value < 0 or value % 1 ~= 0 then
    error(name .. " must be a non-negative integer", 2)
  end
end

function M.Generate(length)
  assert_non_negative_integer(length, "length")
  local output = {}
  local cursor = 1
  local remaining = length

  while remaining > 0 do
    if cursor % 10 == 0 then
      local marker = tostring(cursor // 10)
      local chunk = marker:sub(1, remaining)
      output[#output + 1] = chunk
      remaining = remaining - #chunk
      cursor = cursor + #marker
    else
      output[#output + 1] = tostring(cursor % 10)
      remaining = remaining - 1
      cursor = cursor + 1
    end
  end

  return table.concat(output)
end

function M.GetMarkerCompleteLength(length)
  assert_non_negative_integer(length, "length")
  local cursor = 1

  while cursor <= length do
    if cursor % 10 == 0 then
      local marker_length = #tostring(cursor // 10)
      local marker_end = cursor + marker_length - 1
      if length < marker_end then
        return marker_end
      end
      cursor = cursor + marker_length
    else
      cursor = cursor + 1
    end
  end

  return length
end

function M.GenerateMarkerComplete(length)
  return M.Generate(M.GetMarkerCompleteLength(length))
end

function M.FindFirstMismatch(expected, received)
  local shared_length = math.min(#expected, #received)
  for index = 1, shared_length do
    local expected_char = expected:sub(index, index)
    local received_char = received:sub(index, index)
    if expected_char ~= received_char then
      return { position = index, expected = expected_char, received = received_char }
    end
  end

  if #expected == #received then
    return nil
  end

  local position = shared_length + 1
  return {
    position = position,
    expected = position <= #expected and expected:sub(position, position) or nil,
    received = position <= #received and received:sub(position, position) or nil,
  }
end

function M.Validate(receivedText, expectedLength)
  local expected = M.Generate(expectedLength)
  local mismatch = M.FindFirstMismatch(expected, receivedText)
  local truncation_point = nil

  if mismatch ~= nil and #receivedText < expectedLength and expected:sub(1, #receivedText) == receivedText then
    truncation_point = #receivedText + 1
  end

  return {
    is_valid = mismatch == nil,
    expected_length = expectedLength,
    received_length = #receivedText,
    truncation_point = truncation_point,
    first_mismatch = mismatch,
  }
end

function M.FindTruncationPoint(receivedText)
  local mismatch = M.FindFirstMismatch(M.Generate(#receivedText), receivedText)
  return mismatch and mismatch.position or (#receivedText + 1)
end

function M.Locate(fragment)
  if fragment == "" then
    return 1
  end
  local start = M.Generate(M.DEFAULT_SEARCH_LENGTH):find(fragment, 1, true)
  return start or -1
end

local function rrotate(value, count)
  return ((value >> count) | (value << (32 - count))) & 0xffffffff
end

local function to_hex32(value)
  return string.format("%08x", value & 0xffffffff)
end

local K = {
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

function M.HashFragment(fragment)
  local h0, h1, h2, h3 = 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a
  local h4, h5, h6, h7 = 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
  local bit_length = #fragment * 8
  local message = fragment .. string.char(0x80)
  local padding = (56 - (#message % 64)) % 64
  message = message .. string.rep("\0", padding) .. string.pack(">I8", bit_length)

  for chunk_start = 1, #message, 64 do
    local w = {}
    local chunk = message:sub(chunk_start, chunk_start + 63)
    for index = 0, 15 do
      w[index] = string.unpack(">I4", chunk, index * 4 + 1)
    end
    for index = 16, 63 do
      local s0 = rrotate(w[index - 15], 7) ~ rrotate(w[index - 15], 18) ~ (w[index - 15] >> 3)
      local s1 = rrotate(w[index - 2], 17) ~ rrotate(w[index - 2], 19) ~ (w[index - 2] >> 10)
      w[index] = (w[index - 16] + s0 + w[index - 7] + s1) & 0xffffffff
    end

    local a, b, c, d, e, f, g, h = h0, h1, h2, h3, h4, h5, h6, h7
    for index = 0, 63 do
      local s1 = rrotate(e, 6) ~ rrotate(e, 11) ~ rrotate(e, 25)
      local ch = (e & f) ~ ((~e) & g)
      local temp1 = (h + s1 + ch + K[index + 1] + w[index]) & 0xffffffff
      local s0 = rrotate(a, 2) ~ rrotate(a, 13) ~ rrotate(a, 22)
      local maj = (a & b) ~ (a & c) ~ (b & c)
      local temp2 = (s0 + maj) & 0xffffffff
      h, g, f, e, d, c, b, a = g, f, e, (d + temp1) & 0xffffffff, c, b, a, (temp1 + temp2) & 0xffffffff
    end

    h0 = (h0 + a) & 0xffffffff
    h1 = (h1 + b) & 0xffffffff
    h2 = (h2 + c) & 0xffffffff
    h3 = (h3 + d) & 0xffffffff
    h4 = (h4 + e) & 0xffffffff
    h5 = (h5 + f) & 0xffffffff
    h6 = (h6 + g) & 0xffffffff
    h7 = (h7 + h) & 0xffffffff
  end

  return to_hex32(h0) .. to_hex32(h1) .. to_hex32(h2) .. to_hex32(h3)
    .. to_hex32(h4) .. to_hex32(h5) .. to_hex32(h6) .. to_hex32(h7)
end

function M.BuildWindowIndex(windowSize)
  if type(windowSize) ~= "number" or windowSize <= 0 or windowSize % 1 ~= 0 then
    error("windowSize must be a positive integer", 2)
  end
  if windowSize > M.DEFAULT_SEARCH_LENGTH then
    error("windowSize cannot exceed the default search length", 2)
  end

  local tape = M.Generate(M.DEFAULT_SEARCH_LENGTH)
  local index = {}
  for offset = 1, #tape - windowSize + 1 do
    local hash = M.HashFragment(tape:sub(offset, offset + windowSize - 1))
    if index[hash] == nil then
      index[hash] = {}
    end
    index[hash][#index[hash] + 1] = offset
  end
  return index
end

function M.LocateByHash(fragmentHash, windowSize)
  local normalized = fragmentHash:match("^%s*(.-)%s*$"):lower()
  if index_cache[windowSize] == nil then
    index_cache[windowSize] = M.BuildWindowIndex(windowSize)
  end

  local positions = index_cache[windowSize][normalized] or {}
  local copy = {}
  for index, value in ipairs(positions) do
    copy[index] = value
  end
  return copy
end

return M
