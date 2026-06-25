# SPEC-COMPLIANCE - Assembly

- Language: NASM x86-64 assembly
- Runtime/compiler: NASM plus Linux x86-64 syscall ABI; `nasm` is not installed on PATH in the current Windows environment.
- Conformance level: Level 1
- Generate: implemented in `languages/assembly/src/position_tape.asm` for the `TAPE_LENGTH` source constant.
- GenerateMarkerComplete: not implemented in this checkpoint.
- Validate: not implemented in this checkpoint.
- Locate: not implemented in this checkpoint.
- Hash index: not implemented.
- Logger integration: not implemented.
- Known limitations: target-specific Linux syscall program; local `nasm` is missing, so assembly tests were not executed in this environment.
- Fixture SHA-256 verified: not locally verified for Assembly because the assembler is missing.
