require "digest"

module PositionTape
  DEFAULT_SEARCH_LENGTH = 100_003
  @index_cache = {}

  Mismatch = Struct.new(:position, :expected, :received, keyword_init: true)
  ValidationResult = Struct.new(
    :is_valid,
    :expected_length,
    :received_length,
    :truncation_point,
    :first_mismatch,
    keyword_init: true
  )

  module_function

  def Generate(length)
    raise ArgumentError, "length must be non-negative" if length.negative?

    output = +""
    cursor = 1
    while output.length < length
      if (cursor % 10).zero?
        marker = (cursor / 10).to_s
        output << marker[0, length - output.length]
        cursor += marker.length
      else
        output << (cursor % 10).to_s
        cursor += 1
      end
    end
    output
  end

  def GetMarkerCompleteLength(length)
    raise ArgumentError, "length must be non-negative" if length.negative?

    cursor = 1
    while cursor <= length
      if (cursor % 10).zero?
        marker_length = (cursor / 10).to_s.length
        marker_end = cursor + marker_length - 1
        return marker_end if length < marker_end
        cursor += marker_length
      else
        cursor += 1
      end
    end
    length
  end

  def GenerateMarkerComplete(length)
    Generate(GetMarkerCompleteLength(length))
  end

  def FindFirstMismatch(expected, received)
    shared_length = [expected.length, received.length].min
    (0...shared_length).each do |index|
      next if expected[index] == received[index]

      return Mismatch.new(position: index + 1, expected: expected[index], received: received[index])
    end

    return nil if expected.length == received.length

    position = shared_length + 1
    Mismatch.new(
      position: position,
      expected: position <= expected.length ? expected[position - 1] : nil,
      received: position <= received.length ? received[position - 1] : nil
    )
  end

  def Validate(received_text, expected_length)
    expected = Generate(expected_length)
    mismatch = FindFirstMismatch(expected, received_text)
    truncation_point = nil
    if mismatch && received_text.length < expected_length && expected.start_with?(received_text)
      truncation_point = received_text.length + 1
    end

    ValidationResult.new(
      is_valid: mismatch.nil?,
      expected_length: expected_length,
      received_length: received_text.length,
      truncation_point: truncation_point,
      first_mismatch: mismatch
    )
  end

  def FindTruncationPoint(received_text)
    mismatch = FindFirstMismatch(Generate(received_text.length), received_text)
    mismatch ? mismatch.position : received_text.length + 1
  end

  def Locate(fragment)
    return 1 if fragment.empty?

    index = Generate(DEFAULT_SEARCH_LENGTH).index(fragment)
    index ? index + 1 : -1
  end

  def HashFragment(fragment)
    Digest::SHA256.hexdigest(fragment)
  end

  def BuildWindowIndex(window_size)
    raise ArgumentError, "windowSize must be positive" unless window_size.positive?
    raise ArgumentError, "windowSize cannot exceed the default search length" if window_size > DEFAULT_SEARCH_LENGTH

    tape = Generate(DEFAULT_SEARCH_LENGTH)
    index = Hash.new { |hash, key| hash[key] = [] }
    (0..(tape.length - window_size)).each do |offset|
      index[HashFragment(tape[offset, window_size])] << offset + 1
    end
    index
  end

  def LocateByHash(fragment_hash, window_size)
    normalized_hash = fragment_hash.strip.downcase
    @index_cache[window_size] ||= BuildWindowIndex(window_size)
    @index_cache[window_size].fetch(normalized_hash, []).dup
  end

  alias generate Generate
  alias generate_marker_complete GenerateMarkerComplete
  alias get_marker_complete_length GetMarkerCompleteLength
  alias find_first_mismatch FindFirstMismatch
  alias validate Validate
  alias find_truncation_point FindTruncationPoint
  alias locate Locate
  alias hash_fragment HashFragment
  alias build_window_index BuildWindowIndex
  alias locate_by_hash LocateByHash
end
