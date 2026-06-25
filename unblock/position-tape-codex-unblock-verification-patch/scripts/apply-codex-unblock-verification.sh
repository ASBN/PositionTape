#!/usr/bin/env bash
set -euo pipefail
repo_root="${1:-$(pwd)}"
patch_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Applying PositionTape Codex unblock verification patch to $repo_root"

copy_file() {
  local rel="$1"
  mkdir -p "$(dirname "$repo_root/$rel")"
  cp -f "$patch_root/$rel" "$repo_root/$rel"
  echo "Copied $rel"
}

copy_file "codex/config/high-autonomy-with-network.toml"
copy_file "codex/config/position-tape.high-autonomy-network.config.toml"
copy_file "codex/prompts/01-unblock-verification.md"
copy_file "docs/agentic-plan/CODEX_WINDOWS_VERIFICATION_NOTES.md"

agents="$repo_root/AGENTS.md"
addendum="$patch_root/AGENTS.codex-local-addendum.md"
marker="## Local execution policy for Windows"

if [ -f "$agents" ]; then
  if ! grep -qF "$marker" "$agents"; then
    printf '\n' >> "$agents"
    cat "$addendum" >> "$agents"
    echo "Appended Windows execution policy to AGENTS.md"
  else
    echo "AGENTS.md already contains Windows execution policy; skipped append"
  fi
else
  cp -f "$addendum" "$agents"
  echo "Created AGENTS.md from addendum"
fi

echo "Patch applied. Start Codex with:"
echo "codex --cd . --sandbox workspace-write --ask-for-approval never -c sandbox_workspace_write.network_access=true --search"
