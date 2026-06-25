# SPEC-COMPLIANCE — Swift

- Language: Swift
- Runtime/compiler: Swift 6.3.2 is on PATH, but SwiftPM cannot complete in the local Windows environment.
- Conformance level: Level 3
- Generate: Implemented by `PositionTape.Generate(_:)`.
- GenerateMarkerComplete: Implemented by `PositionTape.GenerateMarkerComplete(_:)`.
- Validate: Implemented by `PositionTape.Validate(_:_:)` with mismatch and truncation diagnostics.
- Locate: Implemented by `PositionTape.Locate(_:)` over the canonical 100,003-character search window.
- Hash index: Implemented by `BuildWindowIndex(_:)` and `LocateByHash(_:_:)` using SHA-256 via `CryptoKit`.
- Logger integration: Not implemented.
- Verified locally: no, 2026-06-25
- Validation command: `swift test --package-path languages\swift --cache-path .toolchain-cache\swiftpm`, retried under `vcvars64.bat`.
- Known limitations: without Visual Studio environment SwiftPM cannot find `msvcrt.lib`, `oldnames.lib`, and `msvcprt.lib`; under `vcvars64.bat`, SwiftPM fails with `unresolvablePathComponent`.
- Fixture SHA-256 verified: Covered by the package tests when SwiftPM is configured; not executed locally in this checkpoint.
