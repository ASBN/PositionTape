---
name: position-tape-conformance-runner
description: Build or run conformance checks that compare language implementations against official PositionTape fixtures and hashes.
---

# PositionTape conformance runner skill

Use this skill for cross-language validation, fixture verification and CI checks.


Always obey AGENTS.md and docs/agentic-plan/APPROVALS_AND_PERMISSIONS.md. Stay inside the repository. Update AGENT_RUN_LOG.md after each checkpoint. Use fixtures as the source of truth.


## Required checks

- Confirm no fixture has a trailing newline.
- Confirm UTF-8 byte length equals character length for digit-only fixtures.
- Confirm SHA-256 matches `fixtures/manifest.generated.json`.
- Run each available language test suite.
- Report unavailable toolchains without failing unrelated languages.

## Output

Write human-readable results to `AGENT_RUN_LOG.md`. Machine-readable output may go under `reports/conformance/`.
