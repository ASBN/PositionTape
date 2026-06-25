# SPEC-COMPLIANCE — Swift

- Language: Swift
- Runtime/compiler: Swift 5.9+ package layout; local compiler not available in the current Windows environment.
- Conformance level: Level 3
- Generate: Implemented by `PositionTape.Generate(_:)`.
- GenerateMarkerComplete: Implemented by `PositionTape.GenerateMarkerComplete(_:)`.
- Validate: Implemented by `PositionTape.Validate(_:_:)` with mismatch and truncation diagnostics.
- Locate: Implemented by `PositionTape.Locate(_:)` over the canonical 100,003-character search window.
- Hash index: Implemented by `BuildWindowIndex(_:)` and `LocateByHash(_:_:)` using SHA-256 via `CryptoKit`.
- Logger integration: Not implemented.
- Known limitations: Not locally executed because `swift` is not installed on PATH.
- Fixture SHA-256 verified: Covered by the package tests when Swift is available; not executed locally in this checkpoint.
