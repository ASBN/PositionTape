# PositionTape Specification

## Purpose

PositionTape is a deterministic, human-readable diagnostic text sequence used to identify truncation, offset position, payload mutation, insertions, deletions and reordering in text pipelines.

## Generation rule

Input: non-negative integer `length`.

Output: exactly `length` characters.

Positions are 1-indexed and refer to cursor positions in the generated output.

For cursor position `p`:

- If `p % 10 != 0`, append `p % 10` as a single decimal digit and advance `p` by 1.
- If `p % 10 == 0`, append decimal text of `p / 10`. If this marker is longer than the remaining output capacity, append only the prefix that fits. Advance `p` by the full marker length, even if truncated by exact output length.

## Marker-complete variant

`GenerateMarkerComplete(length)` returns `Generate(adjustedLength)`, where `adjustedLength` is the minimum length required to avoid truncating a marker that starts at or before `length`.

Example: for `length = 10000`, the marker `1000` starts at position `10000`, so the marker-complete length is `10003`.

## Encoding

Official fixtures use UTF-8 without BOM and no trailing newline.

## Canonical checks

The 10,000-character fixture SHA-256 must match the manifest in `fixtures/manifest.generated.json`.
