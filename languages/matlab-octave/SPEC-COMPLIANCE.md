# SPEC-COMPLIANCE — MATLAB/Octave

- Language: MATLAB/Octave
- Runtime/compiler: Octave or MATLAB; `octave` is not installed on PATH in the current Windows environment.
- Conformance level: Level 3 source implementation
- Generate: Implemented by `Generate(length)`.
- GenerateMarkerComplete: Implemented by `GenerateMarkerComplete(length)`.
- Validate: Implemented by `Validate(receivedText, expectedLength)` with mismatch and truncation diagnostics.
- Locate: Implemented by `Locate(fragment)` over the canonical 100,003-character search window.
- Hash index: Implemented by `BuildWindowIndex(windowSize)` and `LocateByHash(fragmentHash, windowSize)`.
- Logger integration: Not implemented.
- Known limitations: Not locally executed because `octave` is not installed on PATH. SHA-256 uses Octave `hash()` when available, MATLAB Java when available, or system `shasum`/`openssl` fallback.
- Fixture SHA-256 verified: Not by the MATLAB/Octave test harness in this checkpoint.
