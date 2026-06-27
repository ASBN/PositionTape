# PositionTape Specification

## Purpose

PositionTape is a deterministic, human-readable diagnostic text sequence used to identify truncation, offset position, payload mutation, insertions, deletions, and reordering in text pipelines.

The sequence is optimized for humans reading captured payloads: most positions show their last digit, while positions divisible by 10 show a decimal marker that helps identify the approximate absolute position.

## Generation Rule

Input: non-negative integer `length`.

Output: exactly `length` characters.

Positions are 1-indexed and refer to cursor positions in the generated output.

For cursor position `p`:

1. If `p % 10 != 0`, append `p % 10` as one decimal digit and advance `p` by 1.
2. If `p % 10 == 0`, append the decimal text of `p / 10` and advance `p` by the full marker length.
3. Multi-character markers occupy consecutive output positions. For example, at position 100 the marker is `10`, occupying positions 100 and 101.
4. The exact-length generator must return exactly `length` characters. If a marker crosses the requested boundary, append only the prefix that fits.

Examples:

- `Generate(0)` returns an empty string.
- `Generate(10)` returns `1234567891`.
- `Generate(11)` returns `12345678911`.
- `Generate(100)` ends with the first character of the marker `10`.
- `Generate(101)` completes the marker `10`.

## Marker-Complete Variant

`GenerateMarkerComplete(length)` returns `Generate(adjustedLength)`, where `adjustedLength` is the minimum length required to avoid truncating the marker that starts at or before `length`.

The function extends only when the requested boundary cuts through a marker:

- `GenerateMarkerComplete(99)` has length 99.
- `GenerateMarkerComplete(100)` has length 101 because marker `10` starts at position 100.
- `GenerateMarkerComplete(101)` has length 101.
- `GenerateMarkerComplete(10000)` has length 10003 because marker `1000` starts at position 10000.

## Required API

Full implementations expose these operations using idiomatic language naming and return types:

- `Generate(length)`: exact-length generator.
- `GenerateMarkerComplete(length)`: marker-complete generator.
- `Locate(fragment)`: returns the 1-indexed first position of `fragment` in the canonical tape search window, or a not-found value.
- `Validate(receivedText, expectedLength)`: compares received text with `Generate(expectedLength)` and reports validity, truncation, and first mismatch details.
- `FindTruncationPoint(receivedText)`: returns the 1-indexed first position where the received text stops matching the canonical tape prefix.
- `FindFirstMismatch(expected, received)`: returns the 1-indexed first mismatch, including missing-side information when lengths differ.
- `BuildWindowIndex(windowSize)`: builds a SHA-256 hash index of fixed-size windows over the canonical tape search window.
- `LocateByHash(fragmentHash, windowSize)`: returns positions associated with a hash produced from a fixed-size fragment.

Level 3 SHA-256 providers must follow `docs/spec/hash-provider-policy.md`.
Hashes are lowercase 64-character SHA-256 hex strings computed over UTF-8
bytes of the exact fragment string.

## Conformance Levels

- Level 0: consumes official fixtures only.
- Level 1: generator functions.
- Level 2: validation and mismatch diagnostics.
- Level 3: direct locate and hash-window index.
- Level 4: idiomatic logger integration.

## Encoding

Official fixtures use UTF-8 without BOM and no trailing newline. Fixture content is ASCII digits only, so byte length and character length are identical for official fixtures.

## Canonical Checks

The official fixture manifest is `fixtures/manifest.generated.json`.

Conformant implementations must verify:

- Fixture file exists.
- Fixture byte length equals manifest `bytes`.
- Fixture SHA-256 equals manifest `sha256`.
- Fixture has no UTF-8 BOM.
- Fixture has no trailing LF or CR.
- Generated content equals the fixture content for all listed exact-length and marker-complete cases.
