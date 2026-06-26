# PositionTape for c

Status: Level 3 implementation.

Target conformance level: 3.

## API

- `position_tape_generate`
- `position_tape_generate_marker_complete`
- `position_tape_validate`
- `position_tape_find_truncation_point`
- `position_tape_find_first_mismatch`
- `position_tape_locate`
- `position_tape_build_window_index`
- `position_tape_locate_by_hash`
- `position_tape_hash_fragment`

## Verify

```powershell
cl /nologo /I languages\c\src languages\c\src\position_tape.c languages\c\tests\position_tape_tests.c /Fe:.\toolchain-c-position_tape_tests.exe
.\toolchain-c-position_tape_tests.exe
```
