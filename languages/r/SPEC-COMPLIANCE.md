# SPEC-COMPLIANCE — R

- Language: R
- Runtime/compiler: Rscript 4.6.0 available on PATH.
- Conformance level: Level 3
- Generate: Implemented by `Generate(length)`.
- GenerateMarkerComplete: Implemented by `GenerateMarkerComplete(length)`.
- Validate: Implemented by `Validate(receivedText, expectedLength)` with mismatch and truncation diagnostics.
- Locate: Implemented by `Locate(fragment)` over the canonical 100,003-character search window.
- Hash index: Implemented by `BuildWindowIndex(windowSize)` and `LocateByHash(fragmentHash, windowSize)`.
- Logger integration: Not implemented.
- Verified locally: yes, 2026-06-26
- Validation command: `Rscript .\languages\r\tests\test_position_tape.R`
- Known limitations: Hashing uses an available system SHA-256 command (`sha256sum`, `shasum`, `openssl`, or `certutil`) because base R does not expose SHA-256 directly.
- Fixture SHA-256 verified: Not by the R test harness; generation and marker-complete boundary behavior are locally tested.
