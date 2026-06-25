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
- Verified locally: no, 2026-06-25
- Validation command: from `languages/rust`, `cargo test`
- Known limitations: `cargo test` failed because rustc could not write `.rmeta` outputs under `languages\rust\target` (`Acceso denegado`) and test linking could not open `msvcrt.lib`.
- Fixture SHA-256 verified: not locally verified for Rust because the local Cargo/MSVC build path is blocked.
