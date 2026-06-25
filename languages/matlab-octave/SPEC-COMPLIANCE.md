# SPEC-COMPLIANCE — MATLAB/Octave

- Language: MATLAB/Octave
- Runtime/compiler: Octave or MATLAB; `octave` is not installed on PATH in the current Windows environment.
- Conformance level: Level 2
- Generate: Implemented by `Generate(length)`.
- GenerateMarkerComplete: Implemented by `GenerateMarkerComplete(length)`.
- Validate: Implemented by `Validate(receivedText, expectedLength)` with mismatch and truncation diagnostics.
- Locate: Implemented by `Locate(fragment)` over the canonical 100,003-character search window.
- Hash index: Not implemented; dependency-free SHA-256 is not included in the core MATLAB/Octave runtime.
- Logger integration: Not implemented.
- Known limitations: Not locally executed because `octave` is not installed on PATH.
- Fixture SHA-256 verified: Not in this Level 2 implementation.
