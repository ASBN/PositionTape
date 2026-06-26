# Goal: Run PositionTape open-source implementation iterations

Read these files first, in order:

1. `AGENTS.md`
2. `AGENT_RUN_LOG.md`
3. `docs/agentic-plan/MVP_DELIVERY_PLAN.md` if present
4. `docs/agentic-plan/IAIAOH_REVIEW_PROTOCOL.md` if present
5. `codex/prompts/01-unblock-verification.md` if present

## Mission

Advance the PositionTape open-source repository through all practical implementation iterations, preserving safety boundaries and leaving reviewable evidence after every checkpoint.

## Global boundaries

- Work only inside the current repository workspace.
- Do not publish packages.
- Do not push to GitHub.
- Do not create releases.
- Do not modify files outside this repository.
- Do not commit unless explicitly asked.
- Do not introduce secrets or credentials.
- Do not remove user-authored work unless it is clearly generated boilerplate and the reason is logged.
- Prefer small, reviewable changes.
- Keep the commercial ASBN utility out of this open-source repository except for high-level documentation boundaries.

## Iteration protocol

For every iteration:

1. Inspect current repository state with `git status --short`.
2. Identify the smallest next valuable checkpoint.
3. Implement it.
4. Run the relevant verification commands available on this machine.
5. Update `AGENT_RUN_LOG.md` with:
   - checkpoint name,
   - files changed,
   - commands run,
   - pass/fail result,
   - blockers,
   - assumptions,
   - next recommended checkpoint.
6. Continue to the next checkpoint without asking for confirmation unless blocked by missing credentials, unsafe operation, publishing, or work outside the repository.

## Required checkpoint order

### Checkpoint 1: verification unblock

- Make sure C# build and no-package C# conformance runner pass.
- If network is available, restore and run xUnit tests.
- Prefer PowerShell on native Windows.
- Skip bash/Python only if unavailable and log why.

### Checkpoint 2: foundation quality

- Ensure the formal spec is complete.
- Ensure fixtures and manifest are canonical.
- Ensure README explains the project, boundaries, and quick start.
- Ensure conformance docs explain how future languages prove compatibility.

### Checkpoint 3: C# package readiness

- Complete `languages/csharp` as the reference implementation.
- Ensure public API, docs, examples, package metadata, and tests are coherent.
- Prepare NuGet metadata but do not publish.

### Checkpoint 4: CLI minimum viable implementation

- Add an OSS CLI if not present, preferably in .NET first.
- Commands should include `generate`, `validate`, `locate`, and fixture verification if practical.
- Keep it simple; do not build the commercial ASBN UI here.

### Checkpoint 5: logger-first .NET integration

- Add or prepare `integrations/serilog` as an enricher/helper, not a sink unless the code proves a sink is necessary.
- Add usage examples and tests where package restore allows.
- Add `integrations/microsoft-extensions-logging` helper if practical.

### Checkpoint 6: reference triad

- Add Python core implementation if Python is available.
- Add JavaScript/TypeScript core implementation if Node/npm is available.
- Both must validate against official fixtures.
- If a runtime is unavailable, create design/docs and log blocker; do not fake test success.

### Checkpoint 7: GitHub Actions and OSS hygiene

- Ensure CI workflows are present and conservative.
- Avoid requiring all 30 languages in every PR.
- Add docs for contributors and language implementation checklist.

### Checkpoint 8: Genkidama expansion plan

- Update the 30-language status matrix.
- Add per-language `SPEC-COMPLIANCE.md` where missing.
- Do not implement all 30 languages in one giant unverified change; prepare backlog and templates.

## Stop conditions

Stop and summarize only when:

- all practical checkpoints above are complete,
- a required tool/credential is missing and no safe local fallback exists,
- tests reveal a real design conflict that needs human decision,
- the only remaining work is publishing/release/credentials,
- or the user explicitly interrupts.

## Final response required from Codex

When stopping, provide:

- final status,
- files changed,
- tests/commands run,
- passing checks,
- failing checks,
- blockers,
- assumptions,
- next recommended `/goal`.
