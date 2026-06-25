# MVP delivery plan for Codex

## Objective

Generate the minimal viable Open Source PositionTape repository with repeatable conformance tests and first-wave language implementations.

## GEN-PT-001 — Foundation

Deliver:

- Root README.
- Spec docs.
- Fixtures.
- Manifest.
- Conformance test cases.
- C# core library.
- C# xUnit tests.
- CI conformance workflow.

Definition of done:

- C# generates the exact fixture hash for 10,000 characters.
- Tests cover 0, 1, 9, 10, 99, 100, 101, 10,000 and marker-complete 10,003.

## GEN-PT-002 — Reference triad

Deliver:

- Python package.
- JavaScript/TypeScript package.
- Cross-language conformance runner.

Definition of done:

- C#, Python and JS/TS generate identical fixtures.

## GEN-PT-003 — Logger first

Deliver:

- Serilog enricher prototype.
- Microsoft.Extensions.Logging helper.
- Pino helper.
- Python logging helper.

Definition of done:

- Each integration can emit a 10,000-character tape and validate whether the captured output was truncated.

## GEN-PT-004 — CLI minimal

Deliver:

- `position-tape generate`
- `position-tape validate`
- `position-tape locate`
- `position-tape hash-index`

Definition of done:

- CLI operates from local fixtures and exits non-zero on validation failure.

## GEN-PT-005 — Genkidama wave 1

Deliver:

- Java, Go, Rust and C++ Level 2+ implementations.

Definition of done:

- Each passes fixture conformance or documents missing local toolchain.
