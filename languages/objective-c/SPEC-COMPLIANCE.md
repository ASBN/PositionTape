# SPEC-COMPLIANCE - Objective-C

- Language: Objective-C
- Runtime/compiler: Clang 21.1.6 is present through Swift, but the Windows toolchain does not provide a Foundation-capable modern Objective-C runtime.
- Conformance level: Level 2
- Generate: implemented as `Generate`.
- GenerateMarkerComplete: implemented as `GenerateMarkerComplete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no exact SHA-256 index is included.
- Logger integration: not implemented.
- Known limitations: local compile fails quickly with `-fobjc-arc is not supported on platforms using the legacy runtime`; Clang also warns that no Visual Studio installation is found. Validate on macOS with Foundation, or plan a future C-hybrid Windows validation path. Level 3 remains deferred until `Locate`, `BuildWindowIndex`, and exact SHA-256 `LocateByHash` can be implemented and tested.
- Fixture SHA-256 verified: not locally verified for Objective-C because the Objective-C runtime/toolchain is incomplete.
