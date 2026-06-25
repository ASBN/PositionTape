module PositionTape

using SHA

export Generate, GenerateMarkerComplete, GetMarkerCompleteLength, Locate, Validate,
    FindTruncationPoint, FindFirstMismatch, BuildWindowIndex, LocateByHash, HashFragment,
    Mismatch, ValidationResult

const DEFAULT_SEARCH_LENGTH = 100_003
const INDEX_CACHE = Dict{Int,Dict{String,Vector{Int}}}()

struct Mismatch
    position::Int
    expected::Union{Char,Nothing}
    received::Union{Char,Nothing}
end

struct ValidationResult
    is_valid::Bool
    expected_length::Int
    received_length::Int
    truncation_point::Union{Int,Nothing}
    first_mismatch::Union{Mismatch,Nothing}
end

function _assert_non_negative(requested_length::Int)
    requested_length < 0 && throw(ArgumentError("length must be non-negative"))
end

function Generate(requested_length::Int)::String
    _assert_non_negative(requested_length)
    output = IOBuffer()
    cursor = 1

    while position(output) < requested_length
        if cursor % 10 == 0
            marker = string(cursor ÷ 10)
            remaining = requested_length - position(output)
            print(output, marker[1:min(lastindex(marker), remaining)])
            cursor += length(marker)
        else
            print(output, cursor % 10)
            cursor += 1
        end
    end

    return String(take!(output))
end

function GetMarkerCompleteLength(requested_length::Int)::Int
    _assert_non_negative(requested_length)
    cursor = 1

    while cursor <= requested_length
        if cursor % 10 == 0
            marker_length = length(string(cursor ÷ 10))
            marker_end = cursor + marker_length - 1
            requested_length < marker_end && return marker_end
            cursor += marker_length
        else
            cursor += 1
        end
    end

    return requested_length
end

GenerateMarkerComplete(requested_length::Int)::String = Generate(GetMarkerCompleteLength(requested_length))

function FindFirstMismatch(expected::AbstractString, received::AbstractString)::Union{Mismatch,Nothing}
    shared_length = min(length(expected), length(received))
    for index in 1:shared_length
        if expected[index] != received[index]
            return Mismatch(index, expected[index], received[index])
        end
    end

    length(expected) == length(received) && return nothing
    position = shared_length + 1
    return Mismatch(
        position,
        position <= length(expected) ? expected[position] : nothing,
        position <= length(received) ? received[position] : nothing,
    )
end

function Validate(receivedText::AbstractString, expectedLength::Int)::ValidationResult
    expected = Generate(expectedLength)
    mismatch = FindFirstMismatch(expected, receivedText)
    truncation_point = nothing

    if mismatch !== nothing && length(receivedText) < expectedLength && startswith(expected, receivedText)
        truncation_point = length(receivedText) + 1
    end

    return ValidationResult(mismatch === nothing, expectedLength, length(receivedText), truncation_point, mismatch)
end

function FindTruncationPoint(receivedText::AbstractString)::Int
    mismatch = FindFirstMismatch(Generate(length(receivedText)), receivedText)
    return mismatch === nothing ? length(receivedText) + 1 : mismatch.position
end

function Locate(fragment::AbstractString)::Int
    isempty(fragment) && return 1
    found = findfirst(fragment, Generate(DEFAULT_SEARCH_LENGTH))
    return found === nothing ? -1 : first(found)
end

HashFragment(fragment::AbstractString)::String = bytes2hex(sha256(Vector{UInt8}(codeunits(fragment))))

function BuildWindowIndex(windowSize::Int)::Dict{String,Vector{Int}}
    windowSize <= 0 && throw(ArgumentError("windowSize must be positive"))
    windowSize > DEFAULT_SEARCH_LENGTH && throw(ArgumentError("windowSize cannot exceed the default search length"))

    tape = Generate(DEFAULT_SEARCH_LENGTH)
    index = Dict{String,Vector{Int}}()
    for offset in 1:(length(tape) - windowSize + 1)
        hash = HashFragment(tape[offset:offset + windowSize - 1])
        push!(get!(index, hash, Int[]), offset)
    end
    return index
end

function LocateByHash(fragmentHash::AbstractString, windowSize::Int)::Vector{Int}
    normalized_hash = lowercase(strip(fragmentHash))
    index = get!(INDEX_CACHE, windowSize) do
        BuildWindowIndex(windowSize)
    end
    return copy(get(index, normalized_hash, Int[]))
end

end
