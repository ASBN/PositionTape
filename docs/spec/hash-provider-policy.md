# PositionTape SHA-256 Provider Policy

## Purpose

Level 3 conformance includes direct fragment location and fixed-window hash lookup. This policy defines the only acceptable hash behavior for that level so every language implementation remains comparable and testable.

## Required Hash Semantics

Level 3 requires exact SHA-256 over the UTF-8 bytes of the exact fragment string.

`HashFragment(fragment)` must return a lowercase 64-character hexadecimal SHA-256 digest. The input is encoded as UTF-8 before hashing. Official fixtures are ASCII, but hash providers must also handle non-ASCII Unicode strings by hashing their UTF-8 byte sequence.

The following are not substitutes for SHA-256:

- SHA3, including SQLite `sha3(...)`.
- MD5 or SHA1.
- Platform-default hash functions whose algorithm can change or is not explicitly SHA-256.
- Non-cryptographic hashes such as CRC, xxHash, FNV, MurmurHash, language object hashes, or randomized process-local hashes.

Shelling out once for a small direct hash test may be documented as a diagnostic probe only. Shelling out per window inside `BuildWindowIndex` is not acceptable because it hides runtime availability problems and makes Level 3 lookup impractically slow.

Every Level 3 hash provider must pass the shared vectors in `fixtures/sha256-vectors.json`.

## Public API

Full Level 3 implementations expose these operations with idiomatic language spelling while preserving these semantics:

- `HashFragment(fragment)`: hashes one exact fragment string as UTF-8 and returns lowercase SHA-256 hex.
- `BuildWindowIndex(windowSize)`: builds an index from lowercase SHA-256 hex to all 1-indexed positions whose canonical tape window of `windowSize` characters hashes to that value.
- `LocateByHash(fragmentHash, windowSize)`: normalizes a supplied SHA-256 hex digest case-insensitively and returns all matching 1-indexed positions for `windowSize`.

Implementations may cache window indexes by `windowSize`. Caches must not change lookup results.

## Invalid Input Behavior

Language-specific exceptions, error return values, or result objects are acceptable, but invalid inputs must fail explicitly.

- `HashFragment` rejects null or non-string fragments. Empty string is valid and hashes to the standard SHA-256 empty digest.
- `BuildWindowIndex` rejects non-integer, zero, or negative `windowSize` values. It also rejects a `windowSize` larger than the implementation's canonical search window.
- `LocateByHash` rejects null, non-string, empty, non-hex, or non-64-character hashes after trimming surrounding whitespace. Uppercase hex is accepted by normalizing to lowercase. It applies the same `windowSize` rules as `BuildWindowIndex`.

Implementations must not silently fall back to another hash algorithm when SHA-256 is unavailable.

## Provider Strategy Matrix

| Strategy | Languages | Recommendation |
|---|---|---|
| Native standard library SHA-256 | C#, Java, JavaScript/Node, Python, Go, Kotlin, PHP, Ruby, Prolog, VB.NET, Julia | Preferred when the runtime API explicitly provides SHA-256 over UTF-8 bytes. |
| Native/runtime SHA-256 with performance gate | R, MATLAB/Octave, Swift | Accept only when exact SHA-256 is available and `BuildWindowIndex` completes within the language's normal test budget. R is acceptable if the current verified path remains available. MATLAB/Octave is acceptable only if exact `hash("sha256", ...)` works without per-window shelling out and performance is acceptable. Swift remains pending local runtime validation on Windows. |
| Accepted ecosystem dependency | Perl | Accept when the dependency is already standard for the language implementation, lock-free or locally available in the repo's supported path, and passes the shared vectors. Do not add new dependencies without documenting why the standard runtime is insufficient. |
| Pure language implementation | C, C++, Dart, Ada, Delphi/Object Pascal, OCaml if needed, Fortran if current implementation is pure and verified, Lua, Rust, Standard ML | Accept when the implementation is deterministic, dependency-free, vector-tested, and covered by Level 3 tests. Prefer this path for languages without a simple standard SHA-256 runtime. |
| Shared C provider / hybrid | SQLite loadable extension, Objective-C on Windows if Foundation/CommonCrypto is unavailable, COBOL if pure COBOL SHA-256 is not practical, Assembly if pure NASM SHA-256 is not practical | Accept when the native language can call a small repo-owned C SHA-256 provider without per-window process spawning. The provider must pass shared vectors directly and through the language binding. A source-only shared provider is available under `tools/native/sha256/`; generated binaries must not be committed. |
| Not Level 3 candidate in current alpha | Scratch | Scratch remains out of Level 3 unless a concrete `.sb3` project and executable validation path exist. |
| Source-only pending runtime validation | Rust, Swift, MATLAB/Octave | Do not claim locally verified Level 3 until the runtime path completes the shared vectors and hash-window tests. |

## Current Alpha Decisions

- SQLite remains Level 2 until an exact SHA-256 provider is available. SQLite SHA3 is useful evidence of extension capability but is not Level 3 evidence.
- MATLAB/Octave hash-window lookup remains source-only pending runtime validation while `BuildWindowIndex` / `LocateByHash` is slow or unstable on the current Windows Octave path.
- Objective-C on Windows should use a shared C provider if Foundation/CommonCrypto is unavailable.
- COBOL and Assembly should prefer a shared C provider unless a maintainable pure implementation proves practical.
- GEN-PT-027 proved a COBOL-to-C SHA-256 vector binding for ASCII fixtures, but COBOL remains Level 1 until the COBOL public API includes direct locate and hash-window operations.
- GEN-PT-027 proved a minimal Win64 NASM object can execute through a C harness, but Assembly remains Level 1 because the checked-in generator still targets Linux syscalls and has no hash-window API.
