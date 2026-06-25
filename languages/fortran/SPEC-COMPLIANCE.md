# SPEC-COMPLIANCE - Fortran

- Language: Fortran
- Runtime/compiler: `gfortran`; not installed on PATH in the current Windows environment.
- Conformance level: Level 2
- Generate: implemented as `generate`.
- GenerateMarkerComplete: implemented as `generate_marker_complete`.
- Validate: implemented with expected/received lengths, first mismatch, and truncation point.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no dependency-free SHA-256 index included.
- Logger integration: not implemented.
- Known limitations: local `gfortran` is missing, so Fortran tests were not executed in this environment.
- Fixture SHA-256 verified: not locally verified for Fortran because the Fortran toolchain is missing.
