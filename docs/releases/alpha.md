# PositionTape Alpha Release Notes

Status: public GitHub alpha source snapshot.

Tag `v0.1.0-alpha.1` has been cut. No language packages have been published and no GitHub Release artifact has been created yet.

## Verified

- The repository purpose, algorithm summary, conformance model, language status matrix, and blocker notes are documented in the root `README.md`.
- The latest validation status is tracked in root `SPEC-COMPLIANCE.md`.
- Official fixtures live under `fixtures/` with canonical metadata in `fixtures/manifest.generated.json`.
- Shared SHA-256 vectors live in `fixtures/sha256-vectors.json` and define the exact Level 3 hash-provider contract.
- Public CI is limited to portable GitHub-hosted checks: Python fixture conformance and C# baseline conformance/tests on `ubuntu-latest`.
- Governance files are present: `LICENSE`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, and `AGENTS.md`.
- IDE entry points are present for common developer flows: Visual Studio and .NET via `.slnx`, VS Code via `PositionTape.code-workspace`, Rider guidance, and a minimal Codespaces/devcontainer path.
- `.gitignore` excludes common generated outputs across .NET, C/C++, Rust, Go, Swift, OCaml, Java/Kotlin, JavaScript, Python, toolchain logs, OS files, and editor metadata.
- SQLite is verified at Level 3 when the repo-local `sha256(text)` loadable extension is built and loaded.
- Ada and Delphi/Object Pascal are verified at Level 3 with pure language SHA-256 implementations.
- COBOL and Assembly hybrid feasibility was proven through shared C provider/ABI probes, but neither is classified as Level 3.

## Experimental

- Multi-language implementations exist at different conformance levels.
- IDE visibility does not imply all language folders are buildable in a single IDE or default devcontainer.
- Several locally verified languages validate API behavior and marker boundary behavior but do not yet read every official fixture file directly.
- Level 3 hash-window behavior requires exact SHA-256 as defined in
  `docs/spec/hash-provider-policy.md`; SHA3 and platform-default hashes are not
  substitutes.
- Logger integration scope is reserved but not a release-grade alpha claim.
- Scratch is a Level 1 implementation guide only; no binary `.sb3` project is generated.

## Blocked / Not Yet Release-Grade

- MATLAB/Octave has Level 3 source, but the full hash-window test is too slow or unstable on the current Windows Octave 11.3.0 path.
- Objective-C has Level 2 source, but local Windows validation is blocked by the Objective-C runtime/Foundation setup and incomplete no-Foundation Clang header path.
- COBOL remains Level 1 plus a hybrid SHA-256 binding probe; full diagnostics, direct locate, and hash-window APIs are not implemented.
- Assembly remains Level 1 plus a minimal Win64 NASM-to-C ABI probe; the checked-in generator still targets Linux syscalls and has no hash-window API.
- Scratch remains a Level 1 implementation guide/scaffold only.
- Perl, Rust, and Swift remain source-only or blocked pending clean local/CI runtime validation.
- Rust source is present, but local `cargo test` remains blocked by MSVC linker library discovery for `msvcrt.lib`.
- Swift source is present, but local Swift-on-Windows validation is blocked by the installed Visual Studio 2026/18 toolset layout.
- No language packages should be published until the target package-specific test and conformance command passes in a clean CI or release environment.

## Practical Alpha Follow-Up Gate

Before creating any follow-up alpha tag, GitHub release, or package release:

1. Run the portable CI checks.
2. Run the locally available language checks listed in `SPEC-COMPLIANCE.md`.
3. Confirm `git status --short` contains only intentional source/docs changes.
4. Verify that no generated binaries, build outputs, logs, caches, or local diagnostics are staged.
