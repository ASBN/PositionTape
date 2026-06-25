# SPEC-COMPLIANCE - C++

- Language: C++17
- Runtime/compiler: CMake with MSVC Build Tools
- Conformance level: Level 3 source implementation
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- FindTruncationPoint: implemented
- FindFirstMismatch: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with header-only SHA-256 fixed-size windows
- Logger integration: not implemented
- Verified locally: yes, 2026-06-25
- Validation command: `cmake -S .\languages\cpp -B .\languages\cpp\build`; `cmake --build .\languages\cpp\build --config Release`; `ctest --test-dir .\languages\cpp\build --output-on-failure -C Release`
- Known limitations: none for Level 3 scope
- Fixture SHA-256 verified: exact `Generate(10000)` SHA verified; marker-complete boundary lengths verified
