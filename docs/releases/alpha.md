# PositionTape Alpha Release Notes

Status: release-readiness draft for the first public GitHub alpha. No packages
have been published, no GitHub release has been created, and no tag has been
cut.

## Verified

- The repository purpose, algorithm summary, conformance model, language status
  matrix, and blocker notes are documented in the root `README.md`.
- The latest validation status is tracked in root `SPEC-COMPLIANCE.md`.
- Official fixtures live under `fixtures/` with canonical metadata in
  `fixtures/manifest.generated.json`.
- Public CI is limited to portable GitHub-hosted checks: Python fixture
  conformance and C# baseline conformance/tests on `ubuntu-latest`.
- Governance files are present: `LICENSE`, `CONTRIBUTING.md`, `SECURITY.md`,
  `CODE_OF_CONDUCT.md`, and `AGENTS.md`.
- `.gitignore` excludes common generated outputs across .NET, C/C++, Rust, Go,
  Swift, OCaml, Java/Kotlin, JavaScript, Python, toolchain logs, OS files, and
  editor metadata.

## Experimental

- Multi-language implementations exist at different conformance levels.
- Several locally verified languages validate API behavior and marker boundary
  behavior but do not yet read every official fixture file directly.
- Logger integration scope is reserved but not a release-grade alpha claim.
- Scratch is a Level 1 implementation guide only; no binary `.sb3` project is
  generated.

## Blocked / Not Yet Release-Grade

- Ada, Assembly, COBOL, Delphi/Object Pascal, Fortran, Kotlin,
  MATLAB/Octave, Objective-C, Perl, PHP, Ruby, Rust, and Swift were not locally
  validated in the latest checkpoint because required tools were missing or the
  local Windows toolchain could not link/run them.
- Rust source is present, but local `cargo test` remains blocked by MSVC linker
  library discovery for `msvcrt.lib`.
- Swift source is present, but local Swift-on-Windows validation is blocked by
  the installed Visual Studio 2026/18 toolset layout.
- No language packages should be published until the target package-specific
  test and conformance command passes in a clean CI or release environment.

## Practical Alpha Gate

Before creating a public alpha release, run the portable CI checks, run the
locally available language checks listed in `SPEC-COMPLIANCE.md`, confirm
`git status --short` contains only intentional source/docs changes, and verify
that no generated binaries, build outputs, logs, caches, or local diagnostics
are staged.
