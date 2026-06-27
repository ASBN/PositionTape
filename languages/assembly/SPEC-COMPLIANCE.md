# SPEC-COMPLIANCE - Assembly

- Language: NASM x86-64 assembly
- Runtime/compiler: NASM 2.16.01 is available and can assemble the source as ELF64; it also accepts `-f win64`, but the code still uses Linux syscall numbers.
- Conformance level: Level 1
- Generate: implemented in `languages/assembly/src/position_tape.asm` for the `TAPE_LENGTH` source constant.
- GenerateMarkerComplete: not implemented in this checkpoint.
- Validate: not implemented in this checkpoint.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented; no exact SHA-256 path is claimed.
- Logger integration: not implemented.
- Verified locally: partial, 2026-06-27; `nasm -f elf64` assembled in about 0.1 seconds, and `nasm -f win64` also assembled in about 0.1 seconds. GEN-PT-027 also assembled a temporary Win64 NASM function, linked it with a C harness using GCC, and executed `OK assembly c abi`. That proves a future callable-object path, not the current Linux syscall generator.
- Validation command: in WSL/Linux with NASM installed, `sh languages/assembly/tests/verify_position_tape_100.sh`
- Known limitations: target-specific Linux syscall program; running the linked program still requires Linux/WSL. A future Windows runner would need Win64 process/console calls or a callable ABI wrapper. Level 3 is deferred because the implementation still lacks a callable PositionTape API plus exact SHA-256 hash-window support.
- Fixture SHA-256 verified: not locally verified for Assembly because the Linux binary was not executed.
