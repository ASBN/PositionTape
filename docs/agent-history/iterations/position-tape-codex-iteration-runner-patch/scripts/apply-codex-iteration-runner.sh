#!/usr/bin/env bash
set -euo pipefail
repo_root="${1:-$(pwd)}"
patch_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Applying PositionTape Codex iteration runner patch to $repo_root"

copy_file() {
  local rel="$1"
  mkdir -p "$(dirname "$repo_root/$rel")"
  cp -f "$patch_root/$rel" "$repo_root/$rel"
  echo "Copied $rel"
}

copy_file "codex/prompts/99-run-all-iterations.md"
copy_file "codex/prompts/98-review-and-tighten.md"
copy_file "docs/agentic-plan/CODEX_ITERATION_RUNBOOK.md"

agents="$repo_root/AGENTS.md"
addendum="$patch_root/AGENTS.agentic-iteration-addendum.md"
marker="## Agentic iteration policy"

if [ -f "$agents" ]; then
  if ! grep -qF "$marker" "$agents"; then
    printf '\n' >> "$agents"
    cat "$addendum" >> "$agents"
    echo "Appended agentic iteration policy to AGENTS.md"
  else
    echo "AGENTS.md already contains agentic iteration policy; skipped append"
  fi
else
  cp -f "$addendum" "$agents"
  echo "Created AGENTS.md from addendum"
fi

echo "Patch applied. Paste the /goal from codex/prompts/99-run-all-iterations.md or from the assistant response."
