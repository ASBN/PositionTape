# SPEC-COMPLIANCE - Rust

- Language: Rust
- Runtime/compiler: not available in this local environment
- Conformance level: Level 3 source implementation
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- FindTruncationPoint: implemented
- FindFirstMismatch: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with pure Rust SHA-256 fixed-size windows
- Logger integration: not implemented
- Known limitations: local `rustc`/`cargo` are missing, so Rust tests were not executed in this environment
- Fixture SHA-256 verified: not locally verified for Rust because the Rust toolchain is missing
