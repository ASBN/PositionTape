# SPEC-COMPLIANCE — MATLAB/Octave

- Language: MATLAB/Octave
- Runtime/compiler: GNU Octave 11.3.0 is on PATH as both `octave` and `octave-cli`.
- Conformance level: Level 3 source implementation
- Generate: Implemented by `Generate(length)`.
- GenerateMarkerComplete: Implemented by `GenerateMarkerComplete(length)`.
- Validate: Implemented by `Validate(receivedText, expectedLength)` with mismatch and truncation diagnostics.
- Locate: Implemented by `Locate(fragment)` over the canonical 100,003-character search window.
- Hash index: Implemented by `BuildWindowIndex(windowSize)` and `LocateByHash(fragmentHash, windowSize)`.
- Logger integration: Not implemented.
- Known limitations: The non-index portions of the test printed `OK octave pre-index`, but Octave did not exit cleanly before the 60-second timeout and the full test previously hung in the `BuildWindowIndex(length(fragment))` / `LocateByHash` section. SHA-256 uses Octave `hash()` when available, MATLAB Java when available, or system `shasum`/`openssl` fallback.
- Fixture SHA-256 verified: Not by the MATLAB/Octave test harness in this checkpoint.
