# PositionTape for MATLAB/Octave

Status: Level 3 source implementation pending runtime validation.

This folder provides dependency-free MATLAB/Octave functions for generation,
validation, mismatch diagnostics, truncation detection, direct locate, and
SHA-256 hash-window lookup. Level 3 requires exact SHA-256 under
`../../docs/spec/hash-provider-policy.md`; per-window shell hash fallback is
not an accepted provider strategy.

Run the local checks with Octave. The full Level 3 hash-window test is slow on
the current Windows Octave 11.3.0 path because `BuildWindowIndex` hashes nearly
100,000 windows.

```powershell
octave-cli --no-gui --quiet languages/matlab-octave/tests/position_tape_tests.m
```
