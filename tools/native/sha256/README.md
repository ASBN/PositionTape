# PositionTape native SHA-256 provider

This source-only C provider computes exact SHA-256 over UTF-8 bytes and returns
lowercase hexadecimal text. It exists for constrained hybrid language bindings
that can call C but do not have a practical standard SHA-256 runtime.

The implementation is repo-owned and adapted from
`languages/sqlite/extensions/sha256/sha256_extension.c`; both files are part of
the Apache-2.0 PositionTape source tree. No generated binaries should be
committed.

ABI notes:

- `position_tape_sha256_hex(input, length, output_hex)` is the plain C API.
- `input` is treated as an exact byte buffer; callers are responsible for UTF-8
  encoding before the call.
- `output_hex` must have space for 65 bytes and receives a NUL-terminated
  lowercase digest.
- `position_tape_sha256_hex_cobol(input, length, output_hex)` is for GnuCOBOL
  fixed buffers and writes exactly 64 digest characters to `output_hex`.
