# PositionTape for Assembly

Status: Level 1 implementation.

This folder contains a dependency-free NASM x86-64 Linux generator. It reads no
arguments; the source constant `TAPE_LENGTH` controls output length, and the
program writes exact-length tape bytes to standard output with no trailing
newline.

Run the local check on a Linux/NASM environment:

```bash
nasm -f elf64 languages/assembly/src/position_tape.asm -o /tmp/position_tape.o
ld /tmp/position_tape.o -o /tmp/position_tape
/tmp/position_tape | cmp - fixtures/position_tape_100.txt
```
