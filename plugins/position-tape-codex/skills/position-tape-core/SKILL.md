---
name: position-tape-core
description: Implement or review the PositionTape core algorithm, fixtures, spec compliance and exact generation behavior.
---

# PositionTape core skill

Use this skill when implementing, reviewing or fixing the core PositionTape algorithm.


Always obey AGENTS.md and docs/agentic-plan/APPROVALS_AND_PERMISSIONS.md. Stay inside the repository. Update AGENT_RUN_LOG.md after each checkpoint. Use fixtures as the source of truth.


## Required steps

1. Read `docs/spec/position-tape-spec.md`.
2. Read `fixtures/manifest.generated.json`.
3. Implement exact-length generation first.
4. Implement marker-complete generation second.
5. Add tests for boundary lengths: 0, 1, 9, 10, 11, 99, 100, 101, 1000, 10000 and marker-complete 10003.
6. Verify SHA-256 for official fixtures.
7. Do not change fixtures unless explicitly asked.

## Common bug to avoid

At position 100, emit `10` and advance to position 102. Around that area the sequence contains `...1234567891023456789...`.
