# Contributing

Thank you for helping PositionTape. Start by reading `docs/spec/position-tape-spec.md` and validating changes against fixtures.

Do not change fixture outputs unless the specification changes through an explicit ADR.

## Before opening a change

- Keep implementation files inside `languages/<language>/` and integrations
  inside `integrations/<logger-or-platform>/`.
- Do not add generated binaries, build folders, logs, caches, or local
  diagnostics to commits.
- Update tests and the relevant language `SPEC-COMPLIANCE.md` when behavior or
  validation status changes.
- Run the narrowest relevant language test first, then run the fixture or C#
  conformance baseline when practical.

## Alpha expectations

The alpha repository is intentionally conservative: no package publishing,
GitHub releases, tags, or expanded algorithm scope should be included in normal
contribution PRs unless maintainers explicitly ask for that release work.
