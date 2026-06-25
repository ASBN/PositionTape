# SPEC-COMPLIANCE - csharp

- Language: csharp
- Runtime/compiler: .NET 8 (`net8.0`)
- Conformance level: Level 3
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- Locate: implemented with a default 100,003-character canonical search window
- Hash index: implemented with SHA-256 fixed-window hashes over the default search window
- Logger integration: not implemented in GEN-PT-001
- Known limitations: locate and hash lookup intentionally use the default bounded search window until a CLI/configurable search horizon is added
- Fixture SHA-256 verified: covered by `PositionTape.Tests`, `tools/conformance/run_conformance.py`, and `tools/conformance/csharp/PositionTape.Conformance`
