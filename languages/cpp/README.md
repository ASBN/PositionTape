# PositionTape for C++

Status: Level 3 implementation.

## API

- `position_tape::generate(int length)`
- `position_tape::generate_marker_complete(int length)`
- `position_tape::validate(const std::string& received_text, int expected_length)`
- `position_tape::find_truncation_point(const std::string& received_text)`
- `position_tape::find_first_mismatch(const std::string& expected, const std::string& received)`
- `position_tape::locate(const std::string& fragment)`
- `position_tape::build_window_index(int window_size)`
- `position_tape::locate_by_hash(const std::string& fragment_hash, int window_size)`
- `position_tape::hash_fragment(const std::string& fragment)`

## Verify

```powershell
cmake -S languages/cpp -B languages/cpp/build
cmake --build languages/cpp/build
.\languages\cpp\build\position_tape_tests.exe
```
