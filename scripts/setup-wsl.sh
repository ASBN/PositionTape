#!/usr/bin/env bash
set -euo pipefail
printf 'PositionTape Codex Bootstrap — WSL setup\n'

if [ ! -f ./AGENTS.md ]; then
  echo "Run this script from the repository root." >&2
  exit 1
fi

mkdir -p reports/conformance tmp

printf 'Checking common toolchains...\n'
for tool in git dotnet python3 node npm go rustc cargo java; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'OK: %s -> %s\n' "$tool" "$(command -v "$tool")"
  else
    printf 'MISSING: %s\n' "$tool"
  fi
done

printf 'Verifying fixtures...\n'
./scripts/verify-fixtures.sh

cat <<'EOF'
Done. Start Codex with:
  codex --cd . --sandbox workspace-write --ask-for-approval on-request
or, high-autonomy:
  codex --cd . --sandbox workspace-write --ask-for-approval never --search
EOF
