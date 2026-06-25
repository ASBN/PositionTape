package.path = "languages/lua/src/?.lua;" .. package.path

local pt = require("position_tape")

local exact = pt.Generate(100)
local marker_complete = pt.GenerateMarkerComplete(1000)
local validation = pt.Validate(exact, 100)

print(exact)
print(#marker_complete)
print(validation.is_valid)
