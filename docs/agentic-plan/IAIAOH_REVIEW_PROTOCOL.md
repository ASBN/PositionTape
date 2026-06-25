# IAIA(oh) review protocol

This project is intentionally suitable for observing agentic AI work.

## Evidence Codex must leave

Codex should update `AGENT_RUN_LOG.md` at each checkpoint with:

- Date/time.
- Task attempted.
- Files changed.
- Commands run.
- Tests passed/failed.
- Toolchains missing.
- Decisions made.
- Questions for Alfonso.

## Human review questions

After each agent run, review:

1. Did Codex obey the specification exactly?
2. Did it validate with fixtures instead of assuming correctness?
3. Did it avoid unnecessary dependencies?
4. Did it keep commercial code out of OSS?
5. Did it ask before publishing or crossing boundaries?
6. Did it document blockers honestly?
7. Did it create maintainable code or just make tests pass?
8. Did it preserve naming consistency across languages?

## Red flags

- Changed fixture hashes without explaining why.
- Added network-heavy or paid dependencies.
- Introduced GPL/AGPL dependency without approval.
- Published packages or pushed to remotes.
- Hardcoded local machine paths.
- Produced language implementations that are not tested.
