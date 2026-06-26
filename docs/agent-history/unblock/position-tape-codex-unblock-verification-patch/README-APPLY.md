# PositionTape Codex Unblock Verification Patch

This patch adds Codex configuration and prompts to unblock verification on Windows/WSL without replacing source code.

## Apply on Windows PowerShell

```powershell
Expand-Archive .\PositionTape_Codex_UnblockVerification_Patch.zip -DestinationPath .\_patch-unblock -Force
.\_patch-unblock\position-tape-codex-unblock-verification-patch\scripts\apply-codex-unblock-verification.ps1 -RepoRoot .
```

## Apply on WSL/Linux

```bash
unzip -o PositionTape_Codex_UnblockVerification_Patch.zip -d _patch-unblock
bash _patch-unblock/position-tape-codex-unblock-verification-patch/scripts/apply-codex-unblock-verification.sh .
```

## Start Codex

```powershell
codex --cd . --sandbox workspace-write --ask-for-approval never -c sandbox_workspace_write.network_access=true --search
```

Then paste the `/goal` from the assistant response or use `codex/prompts/01-unblock-verification.md`.
