# SPEC-COMPLIANCE - Ada

- Language: Ada
- Runtime/compiler: GNAT 16.1.0 available on PATH and verified locally.
- Conformance level: Level 2
- Generate: implemented as `Generate`.
- GenerateMarkerComplete: implemented as `Generate_Marker_Complete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no exact SHA-256 index is included.
- Logger integration: not implemented.
- Verified locally: Level 2 test command passed with `gnatmake -Ilanguages/ada/src languages/ada/tests/position_tape_tests.adb` from a temp build directory.
- Known limitations: Level 3 remains deferred until `Locate`, `BuildWindowIndex`, and exact SHA-256 `LocateByHash` can be implemented and tested. A pure Ada SHA-256 implementation is not included in this checkpoint.
- Fixture SHA-256 verified: not locally verified for Ada because hash-window APIs are not implemented.
