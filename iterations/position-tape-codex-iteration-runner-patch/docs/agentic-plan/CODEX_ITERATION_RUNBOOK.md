# Codex iteration runbook

This document exists to keep long-running Codex work reviewable.

## Operating mode

Recommended command:

```powershell
codex --cd . --sandbox workspace-write --ask-for-approval never -c sandbox_workspace_write.network_access=true --search
```

This permits autonomous work inside the repository and network access for package restore. It does not authorize publishing or modifying files outside the repository.

## Iteration principles

- One checkpoint at a time.
- Always update `AGENT_RUN_LOG.md`.
- Always run the closest available verification command.
- Prefer working code over broad plans.
- Prefer source + tests + docs together.
- Treat missing tools as blockers, not code defects.
- Never claim tests passed unless they were actually run.

## Human review rhythm

After Codex stops:

1. Run `git status --short`.
2. Review `AGENT_RUN_LOG.md` first.
3. Review changed files by checkpoint.
4. Run the verification commands Codex reported.
5. Commit only after human review.

## IAIA(oh) evidence

For later IAIA(oh) review, the important evidence is:

- what Codex chose to do next,
- whether it preserved boundaries,
- whether it reported blockers honestly,
- whether it tested what it changed,
- whether it invented success or left reproducible commands.
