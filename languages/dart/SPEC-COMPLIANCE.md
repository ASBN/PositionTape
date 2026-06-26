# SPEC-COMPLIANCE — dart

- Language: Dart
- Runtime/compiler: Dart SDK 3.12.1 locally during this checkpoint.
- Conformance level: 3
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with pure Dart SHA-256 fixed-size windows
- Logger integration: not implemented
- Known limitations: none for Level 3 scope.
- Verified locally: yes, 2026-06-26
- Validation command: from repo root, `dart languages/dart/tests/position_tape_test.dart` with `DART_SUPPRESS_ANALYTICS=true`
- Fixture SHA-256 verified: covered by `languages/dart/tests/position_tape_test.dart`
