# SPEC-COMPLIANCE - Fortran

- Language: Fortran
- Runtime/compiler: `gfortran` available on PATH; SHA-256 uses installed Perl `Digest::SHA`.
- Conformance level: Level 3
- Generate: implemented as `generate`.
- GenerateMarkerComplete: implemented as `generate_marker_complete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: implemented as `locate`.
- Hash index: implemented as `build_window_index(window_size)` and `locate_by_hash(fragment_hash, window_size)`.
- Logger integration: not implemented.
- Known limitations: hash-window APIs require Perl `Digest::SHA`; no logger integration.
- Fixture SHA-256 verified: not by the Fortran test harness; generation and Level 3 API behavior were locally tested.
