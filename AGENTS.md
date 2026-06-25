# AGENTS.md — PositionTape

## Mission

Build the Open Source PositionTape project: a multi-language, conformance-tested implementation of a human-readable diagnostic tape for truncation and payload-integrity testing.

## Operating mode

Work as an autonomous engineering agent, but stay inside the repository. Prefer small verified checkpoints over large untested rewrites.

## Non-negotiable specification

Positions are 1-indexed.

For cursor position `p`:

1. If `p` is not divisible by 10, emit the last digit of `p`.
2. If `p` is divisible by 10, emit the decimal text of `p / 10`.
3. Multi-character markers occupy consecutive output positions and advance the cursor by the marker length.
4. The exact-length generator must return exactly `N` characters, truncating a marker if it crosses the boundary.
5. The marker-complete generator must extend only when needed so the marker that starts at or before the requested boundary is complete.
6. Generated files are UTF-8, no BOM, no newline unless a language ecosystem forces one for packaging examples. Fixtures must have no newline.

## Required public API per full implementation

- `Generate(length)`
- `GenerateMarkerComplete(length)`
- `Locate(fragment)`
- `Validate(receivedText, expectedLength)`
- `FindTruncationPoint(receivedText)`
- `FindFirstMismatch(expected, received)`
- `BuildWindowIndex(windowSize)`
- `LocateByHash(fragmentHash, windowSize)`

## Conformance levels

- Level 0: consumes official fixtures only.
- Level 1: generator functions.
- Level 2: validation and mismatch diagnostics.
- Level 3: direct locate and hash-window index.
- Level 4: idiomatic logger integration.

## Repository discipline

- Always update tests when behavior changes.
- Always validate against `fixtures/manifest.generated.json`.
- Do not change the algorithm to make a language easier.
- Do not add dependencies for the core generator unless the language makes it unavoidable.
- Keep each language implementation in `languages/<language>/`.
- Keep logger integrations in `integrations/<logger-or-platform>/`.
- Keep commercial ASBN code out of this repository.

## Build and test expectations

Run the narrowest relevant tests first, then the conformance runner. If a toolchain is missing locally, document it in `AGENT_RUN_LOG.md` and continue with languages whose toolchains are available.

## Commit hygiene

Use clear checkpoint summaries. Suggested commit message format:

`GEN-PT-00X: <short outcome>`

Do not publish, tag, push, or release packages unless the user explicitly asks.
