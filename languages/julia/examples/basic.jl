include("../src/PositionTape.jl")

using .PositionTape

exact = Generate(100)
marker_complete = GenerateMarkerComplete(1000)
validation = Validate(exact, 100)

println(exact)
println(length(marker_complete))
println(validation.is_valid)
