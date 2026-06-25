# SPEC-COMPLIANCE — R

- Language: R
- Runtime/compiler: Rscript 4.6.0 available on PATH.
- Conformance level: Level 2
- Generate: Implemented by `Generate(length)`.
- GenerateMarkerComplete: Implemented by `GenerateMarkerComplete(length)`.
- Validate: Implemented by `Validate(receivedText, expectedLength)` with mismatch and truncation diagnostics.
- Locate: Implemented by `Locate(fragment)` over the canonical 100,003-character search window.
- Hash index: Not implemented; R base does not provide SHA-256 string hashing without optional packages or external tools.
- Logger integration: Not implemented.
- Verified locally: yes, 2026-06-25
- Validation command: `Rscript .\languages\r\tests\test_position_tape.R`
- Known limitations: Hash-window APIs are not implemented at Level 2.
- Fixture SHA-256 verified: Not in this Level 2 implementation; generation and marker-complete boundary behavior were locally tested.
