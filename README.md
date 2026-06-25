# PositionTape Codex Bootstrap

This repository is a minimal viable scaffold for building the Open Source **PositionTape** project with Codex on Windows 11, PowerShell, or WSL.

PositionTape is a human-readable diagnostic tape for truncation and payload-integrity testing. The commercial ASBN product should live separately as **ASBN PositionTape Inspector** or a similar licensed diagnostic utility.

## What this bootstrap contains

- Root `AGENTS.md` for project-level Codex instructions.
- Local Codex plugin scaffold under `plugins/position-tape-codex/`.
- Repo marketplace file under `.agents/plugins/marketplace.json`.
- Skills for specification, language implementation, conformance testing, logger adapters, and OSS hygiene.
- Official fixtures and manifest.
- Scripts for Windows PowerShell and WSL.
- Initial prompts and `/goal` instructions for agentic execution.
- A minimal repo layout for 30 Genkidama languages.

## First run on Windows 11 PowerShell

```powershell
cd C:\Code\position-tape
.\scripts\setup-windows.ps1
codex --cd . --sandbox workspace-write --ask-for-approval on-request
```

For the most agentic local run while staying inside the workspace:

```powershell
codex --cd . --sandbox workspace-write --ask-for-approval never --search
```

Use `--ask-for-approval never` only after reviewing `docs/agentic-plan/APPROVALS_AND_PERMISSIONS.md`.

## First run on WSL

```bash
cd ~/code/position-tape
chmod +x scripts/*.sh
./scripts/setup-wsl.sh
codex --cd . --sandbox workspace-write --ask-for-approval on-request
```

## Recommended first Codex prompt

Open `codex/prompts/00-bootstrap-goal.md`, paste it into Codex, and let Codex work in checkpoints.

## Safety boundary

Codex is allowed to create, modify, delete, build and test files **inside this repository**. It must not publish packages, push to GitHub, modify files outside the workspace, create secrets, rotate credentials, or use `danger-full-access` unless explicitly approved by Alfonso.

## Commercial boundary

The Open Source repo should implement the algorithm, tests, fixtures, language packages and basic logger integrations. The licensed ASBN product should own the compiled inspector, UI, enterprise importers, reports, CI evidence workflows and customer-facing support.
