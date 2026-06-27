# SPEC-COMPLIANCE - Assembly

- Language: NASM x86-64 assembly
- Runtime/compiler: NASM plus Linux x86-64 syscall ABI.
- Conformance level: Level 1
- Generate: implemented in `languages/assembly/src/position_tape.asm` for the `TAPE_LENGTH` source constant.
- GenerateMarkerComplete: not implemented in this checkpoint.
- Validate: not implemented in this checkpoint.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no exact SHA-256 path is claimed.
- Logger integration: not implemented.
- Verified locally: no, 2026-06-26
- Validation command: in WSL/Linux with NASM installed, `sh languages/assembly/tests/verify_position_tape_100.sh`
- Known limitations: target-specific Linux syscall program; WSL returned `Wsl/Service/CreateInstance/E_ACCESSDENIED` in this environment, and the latest WSL diagnostics that reached the script reported `nasm: command not found`. Assembly verification requires NASM inside WSL/Linux. Level 3 is deferred because a callable API plus exact SHA-256 hash-window support is not a short, locally testable change.
- Fixture SHA-256 verified: not locally verified for Assembly because the assembler is missing.
