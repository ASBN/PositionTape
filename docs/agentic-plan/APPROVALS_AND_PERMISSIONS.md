# Codex approvals and permissions for PositionTape

This file is a project policy for Codex and for Alfonso. It does not bypass Codex security by itself; it tells Codex what it may do when the selected sandbox and approval mode allow it.

## Recommended modes

### Safe interactive

```bash
codex --cd . --sandbox workspace-write --ask-for-approval on-request
```

Use this for early runs.

### High-autonomy local workspace

```bash
codex --cd . --sandbox workspace-write --ask-for-approval never --search
```

Use this when you want Codex to work with fewer interruptions. Keep the repository in a disposable branch.

### Do not use by default

```bash
codex --dangerously-bypass-approvals-and-sandbox
```

Only use inside a disposable VM or isolated runner. This repo should not require it.

## Pre-approved inside workspace

Codex may do these without asking when the active approval mode allows it:

- Create, edit, move and delete files inside the repository.
- Generate code, tests, fixtures, docs, examples and workflow files.
- Run tests and build commands inside the repository.
- Create local branches.
- Use package managers for development dependencies when network access is enabled.
- Read official language/tool documentation if web search is enabled.
- Write progress notes to `AGENT_RUN_LOG.md`.

## Must ask Alfonso first

- Publishing to NuGet, npm, PyPI, Maven, crates.io, Go proxy, RubyGems, Packagist or any other package registry.
- Pushing to GitHub or creating releases/tags.
- Adding credentials, tokens, secrets or paid cloud resources.
- Deleting files outside the repository.
- Changing global Git config.
- Using `danger-full-access` or `--dangerously-bypass-approvals-and-sandbox`.
- Adding copyleft dependencies such as GPL/AGPL unless explicitly approved.
- Changing license from Apache-2.0 or MIT.

## Network policy

Network is optional. Prefer offline implementation from the included spec and fixtures. When network is enabled, use it only for official docs, package manager restore/install, and ecosystem validation.

## Stopping condition

Stop and report when:

- The current checkpoint passes tests, or
- A required toolchain is missing, or
- A design decision would affect public API, license, package naming, publishing or commercial boundary.
