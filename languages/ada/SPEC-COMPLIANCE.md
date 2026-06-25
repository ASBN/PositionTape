# SPEC-COMPLIANCE - Ada

- Language: Ada
- Runtime/compiler: GNAT; not installed on PATH in the current Windows environment.
- Conformance level: Level 2
- Generate: implemented as `Generate`.
- GenerateMarkerComplete: implemented as `Generate_Marker_Complete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no dependency-free SHA-256 index included.
- Logger integration: not implemented.
- Known limitations: local `gnat` is missing, so Ada tests were not executed in this environment.
- Fixture SHA-256 verified: not locally verified for Ada because the Ada toolchain is missing.
