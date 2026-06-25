# PositionTape for Rust

Status: Level 3 implementation.

## API

- `generate(length: usize) -> String`
- `generate_marker_complete(length: usize) -> String`
- `validate(received_text: &str, expected_length: usize) -> ValidationResult`
- `find_truncation_point(received_text: &str) -> usize`
- `find_first_mismatch(expected: &str, received: &str) -> Option<Mismatch>`
- `locate(fragment: &str) -> isize`
- `build_window_index(window_size: usize) -> HashMap<String, Vec<usize>>`
- `locate_by_hash(fragment_hash: &str, window_size: usize) -> Vec<usize>`
- `hash_fragment(fragment: &str) -> String`

## Verify

```powershell
cargo test --manifest-path languages/rust/Cargo.toml
```
