# PositionTape for Assembly

Status: Level 1 implementation.

This folder contains a dependency-free NASM x86-64 Linux generator. It reads no
arguments; the source constant `TAPE_LENGTH` controls output length, and the
program writes exact-length tape bytes to standard output with no trailing
newline.

Level 3 is intentionally not attempted in this alpha classification. The file
is a Linux syscall program rather than a callable API surface, and there is no
simple tested SHA-256/hash-window path for Assembly in this repository.

Run the local check on a Linux/NASM environment:

```bash
nasm -f elf64 languages/assembly/src/position_tape.asm -o /tmp/position_tape.o
ld /tmp/position_tape.o -o /tmp/position_tape
/tmp/position_tape | cmp - fixtures/position_tape_100.txt
```

On Windows, NASM can assemble the file, but the source uses Linux syscalls
(`write` and `exit`). A `win64` object is therefore assemble-only evidence, not
a runnable Windows artifact.
