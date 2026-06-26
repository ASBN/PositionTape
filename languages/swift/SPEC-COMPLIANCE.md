# SPEC-COMPLIANCE — Swift

- Language: Swift
- Runtime/compiler: Swift 6.3.2 is on PATH, but the Swift-on-Windows toolchain is incompatible with the current Visual Studio 2026/18 environment.
- Conformance level: Level 3
- Generate: Implemented by `PositionTape.Generate(_:)`.
- GenerateMarkerComplete: Implemented by `PositionTape.GenerateMarkerComplete(_:)`.
- Validate: Implemented by `PositionTape.Validate(_:_:)` with mismatch and truncation diagnostics.
- Locate: Implemented by `PositionTape.Locate(_:)` over the canonical 100,003-character search window.
- Hash index: Implemented by `BuildWindowIndex(_:)` and `LocateByHash(_:_:)` using SHA-256 via `CryptoKit`.
- Logger integration: Not implemented.
- Verified locally: no, 2026-06-26
- Validation command: intended `swift test --package-path languages\swift --cache-path .toolchain-cache\swiftpm`; skipped after `swift --version` crashed.
- Known limitations: `swift --version` crashes with `unsupported toolset layout (VS2017+ required)` under the current Visual Studio 2026/18 environment; treated as a Swift-on-Windows toolchain incompatibility, not a PositionTape source failure.
- Fixture SHA-256 verified: Covered by the package tests when SwiftPM is configured; not executed locally in this checkpoint.
