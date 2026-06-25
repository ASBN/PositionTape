# SPEC-COMPLIANCE — Swift

- Language: Swift
- Runtime/compiler: Swift 6.3.2 is on PATH, but the local Windows linker/MSVC runtime configuration is incomplete.
- Conformance level: Level 3
- Generate: Implemented by `PositionTape.Generate(_:)`.
- GenerateMarkerComplete: Implemented by `PositionTape.GenerateMarkerComplete(_:)`.
- Validate: Implemented by `PositionTape.Validate(_:_:)` with mismatch and truncation diagnostics.
- Locate: Implemented by `PositionTape.Locate(_:)` over the canonical 100,003-character search window.
- Hash index: Implemented by `BuildWindowIndex(_:)` and `LocateByHash(_:_:)` using SHA-256 via `CryptoKit`.
- Logger integration: Not implemented.
- Known limitations: `swift test --package-path languages/swift` cannot compile the package manifest locally because `msvcrt.lib`, `oldnames.lib`, and `msvcprt.lib` are not discoverable after redirecting denied AppData caches to repo-local paths.
- Fixture SHA-256 verified: Covered by the package tests when Swift is configured; not executed locally in this checkpoint because the Swift toolchain cannot link manifests.
