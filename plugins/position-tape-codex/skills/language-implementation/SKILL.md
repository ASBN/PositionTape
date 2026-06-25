---
name: position-tape-language-implementation
description: Add a new PositionTape implementation under languages/<language> with tests, README and conformance metadata.
---

# PositionTape language implementation skill

Use this skill when adding or improving a language under `languages/<language>/`.


Always obey AGENTS.md and docs/agentic-plan/APPROVALS_AND_PERMISSIONS.md. Stay inside the repository. Update AGENT_RUN_LOG.md after each checkpoint. Use fixtures as the source of truth.


## Required folder shape

```text
languages/<language>/
├─ README.md
├─ SPEC-COMPLIANCE.md
├─ src/
├─ tests/
├─ examples/
└─ CHANGELOG.md
```

## Required implementation path

1. Start with `Generate(length)`.
2. Add `GenerateMarkerComplete(length)`.
3. Add `Validate`, `FindTruncationPoint` and `FindFirstMismatch` if the target level is 2+.
4. Add `Locate` and hash-window functions if the target level is 3+.
5. Add the idiomatic package metadata only after tests pass locally or missing toolchain is documented.

## Dependency policy

Core generator should be dependency-free whenever possible.
