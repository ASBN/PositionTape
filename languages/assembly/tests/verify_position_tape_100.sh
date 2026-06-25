#!/usr/bin/env bash
set -euo pipefail

nasm -f elf64 languages/assembly/src/position_tape.asm -o /tmp/position_tape.o
ld /tmp/position_tape.o -o /tmp/position_tape
/tmp/position_tape | cmp - fixtures/position_tape_100.txt
echo "OK assembly"
