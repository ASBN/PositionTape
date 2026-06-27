# PositionTape for Scratch

Status: Level 1 implementation guide.

Scratch projects are binary `.sb3` archives and are awkward to author safely
without a Scratch-specific build tool. This folder therefore provides the
canonical block algorithm in text form so a Scratch project can implement the
same Level 1 generator without changing the PositionTape rules.

Scratch remains guide/scaffold only until a concrete `.sb3` project and
headless or manual verification runtime are defined. No Level 3 API or
hash-window support is claimed.

See `src/position_tape_blocks.md` for the block procedure. Verify manually by
setting `requestedLength` to an official fixture length and comparing the
resulting `tape` variable to the corresponding `fixtures/position_tape_*.txt`
file.
