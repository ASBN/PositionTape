# SPEC-COMPLIANCE - Go

- Language: Go
- Runtime/compiler: go1.26.1 windows/amd64 verified locally
- Conformance level: Level 3
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- FindTruncationPoint: implemented
- FindFirstMismatch: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with SHA-256 fixed-size windows using Go's standard library
- Logger integration: not implemented
- Known limitations: none for Level 3 scope.
- Verified locally: yes, 2026-06-26
- Validation command: from `languages/go`, `go test ./...`
- Fixture SHA-256 verified: yes, via `go test ./...` from `languages/go`
