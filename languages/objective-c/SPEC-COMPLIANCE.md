# SPEC-COMPLIANCE - Objective-C

- Language: Objective-C
- Runtime/compiler: Clang with Foundation; local `clang` is present through Swift, but the Windows Foundation/MSVC runtime setup is incomplete.
- Conformance level: Level 2
- Generate: implemented as `Generate`.
- GenerateMarkerComplete: implemented as `GenerateMarkerComplete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no exact SHA-256 index is included.
- Logger integration: not implemented.
- Known limitations: tests were not executed because the available Windows Clang/Swift environment cannot link MSVC runtime libraries or provide a Foundation-capable Objective-C runtime. Level 3 remains deferred until `Locate`, `BuildWindowIndex`, and exact SHA-256 `LocateByHash` can be implemented and tested.
- Fixture SHA-256 verified: not locally verified for Objective-C because the Objective-C runtime/toolchain is incomplete.
