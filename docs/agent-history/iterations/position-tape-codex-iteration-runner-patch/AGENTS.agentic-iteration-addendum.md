
## Agentic iteration policy

When asked to run all PositionTape iterations:

- Work checkpoint by checkpoint, not as one giant patch.
- Prefer the next smallest valuable implementation step.
- After each checkpoint, run available tests and update `AGENT_RUN_LOG.md`.
- If a tool is missing, log the blocker and continue with safe alternatives.
- Do not publish packages, create releases, push to GitHub, or commit unless explicitly asked.
- Do not implement commercial ASBN-only features in the OSS repo.
- Keep logger integrations thin and idiomatic.
- Keep the C# implementation as the reference implementation until another language reaches conformance.
- Never claim a test passed unless it was actually executed.
