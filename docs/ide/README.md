# IDE Entry Points

PositionTape is a polyglot alpha repository. The IDE files make navigation
easier, but they do not change the conformance status of any language.

## Entry Points

- Visual Studio: open `PositionTape.slnx` for the repository showcase or
  `PositionTape.DotNet.slnx` for .NET-focused build/test work.
- VS Code: open `PositionTape.code-workspace` for a polyglot workspace with
  relative folders and validation tasks.
- Rider: see [rider.md](rider.md). Use `PositionTape.DotNet.slnx` for .NET
  work and the filesystem view for other languages.
- GitHub Codespaces: see [codespaces.md](codespaces.md). The default container
  is intentionally minimal and does not install every language toolchain.

## Validation Source Of Truth

Use root `SPEC-COMPLIANCE.md` for language status. IDE visibility means the
source is easy to browse; it does not mean the language is verified locally or
buildable through that IDE.

## Current Alpha Status Summary

Visual Studio and `dotnet build` entry points are buildable for the .NET
projects only: C#, C# xUnit tests, the C# no-package conformance runner, and
VB.NET source/tests.

The latest terminal-verified language list is: C, C++, C#, Dart, Go, Java,
JavaScript, Julia, Lua, OCaml, Prolog, Python, R, SQLite, Standard ML, and
VB.NET. Some of those validations are API/boundary checks rather than direct
manifest-file checks; see `SPEC-COMPLIANCE.md` for the exact command and
fixture status.

The latest locally blocked list is: Ada, Assembly, COBOL,
Delphi/Object Pascal, Fortran, Kotlin, MATLAB/Octave, Objective-C, Perl, PHP,
Ruby, Rust, and Swift. The source folders remain visible in IDEs for review and
future work, but the alpha does not claim they passed locally.
