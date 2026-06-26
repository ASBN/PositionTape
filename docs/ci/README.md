# CI Policy

PositionTape uses layered CI so the repository can be both honest and useful.

## Workflows

### `conformance.yml`

Purpose: required, fast, stable baseline.

Expected to pass on every push and pull request.

It checks:

- official fixture conformance through Python;
- no-package C# conformance runner;
- C# xUnit tests.

This is the workflow that should become required for branch protection first.

### `polyglot-verified.yml`

Purpose: public proof that the verified language folders are not decorative.

Expected to pass after each CI stabilization checkpoint.

It checks portable, currently verified language implementations with GitHub-hosted runners:

- .NET / C# / VB.NET
- C
- C++
- Java
- Python
- JavaScript
- Go
- Dart
- OCaml
- SQLite
- Prolog
- Julia
- Lua
- R
- Standard ML

If a language listed here fails in CI, either fix the implementation/tooling or move it back to experimental with a clear note.

### `polyglot-experimental.yml`

Purpose: monitoring only for blocked or heavier toolchains.

Allowed to fail by design.

It attempts or inspects:

- Ada
- Assembly
- COBOL
- Delphi/Object Pascal
- Fortran
- Kotlin
- MATLAB/Octave
- Objective-C
- Perl
- PHP
- Ruby
- Rust
- Swift

This workflow should not be used as a branch-protection requirement in the alpha.

## Badge Policy

Show these badges in the README:

- core conformance / master
- polyglot verified / master
- polyglot verified / dev
- tag
- license
- alpha status
- language count

Do not show package badges until packages exist.

Do not show release badges until a GitHub Release exists.
