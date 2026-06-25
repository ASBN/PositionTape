# PositionTape Codex Iteration Runner Patch

This patch adds long-running iteration prompts and an AGENTS.md addendum for autonomous but reviewable Codex work.

## Apply on Windows PowerShell

```powershell
Expand-Archive .\PositionTape_Codex_IterationRunner_Patch.zip -DestinationPath .\_patch-iterations -Force
.\_patch-iterations\position-tape-codex-iteration-runner-patch\scripts\apply-codex-iteration-runner.ps1 -RepoRoot .
```

## Apply on WSL/Linux

```bash
unzip -o PositionTape_Codex_IterationRunner_Patch.zip -d _patch-iterations
bash _patch-iterations/position-tape-codex-iteration-runner-patch/scripts/apply-codex-iteration-runner.sh .
```

## Start Codex

```powershell
codex --cd . --sandbox workspace-write --ask-for-approval never -c sandbox_workspace_write.network_access=true --search
```

Then paste the `/goal` from the assistant response or ask Codex to read `codex/prompts/99-run-all-iterations.md`.
