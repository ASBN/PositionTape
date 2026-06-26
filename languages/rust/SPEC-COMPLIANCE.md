# SPEC-COMPLIANCE - Rust

- Language: Rust
- Runtime/compiler: `cargo` and `rustc` available on PATH, but local Windows build environment is incomplete.
- Conformance level: Level 3 source implementation
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- FindTruncationPoint: implemented
- FindFirstMismatch: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with pure Rust SHA-256 fixed-size windows
- Logger integration: not implemented
- Verified locally: no, 2026-06-26
- Validation command: from `languages/rust`, `cargo test`
- Known limitations: `cargo test` still fails at MSVC link time with `LINK : fatal error LNK1104: no se puede abrir el archivo 'msvcrt.lib'`; this is treated as a local MSVC environment/toolchain blocker, not a PositionTape source failure.
- Fixture SHA-256 verified: not locally verified for Rust because the local Cargo/MSVC build path is blocked.
