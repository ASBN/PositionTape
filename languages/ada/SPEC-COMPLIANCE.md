# SPEC-COMPLIANCE - Ada

- Language: Ada
- Runtime/compiler: GNAT; not installed on PATH in the current Windows environment.
- Conformance level: Level 2
- Generate: implemented as `Generate`.
- GenerateMarkerComplete: implemented as `Generate_Marker_Complete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no exact SHA-256 index is included.
- Logger integration: not implemented.
- Known limitations: local `gnat` is missing, so Ada tests were not executed in this environment. Level 3 remains deferred until `Locate`, `BuildWindowIndex`, and exact SHA-256 `LocateByHash` can be implemented and tested.
- Fixture SHA-256 verified: not locally verified for Ada because the Ada toolchain is missing.
