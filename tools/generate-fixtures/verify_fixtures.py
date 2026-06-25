from __future__ import annotations
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
manifest_path = root / "fixtures" / "manifest.generated.json"
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

for fixture in manifest["fixtures"]:
    path = root / "fixtures" / fixture["file"]
    raw = path.read_bytes()
    sha = hashlib.sha256(raw).hexdigest()
    assert len(raw) == fixture["bytes"], f"length mismatch {path}: {len(raw)} != {fixture['bytes']}"
    assert sha == fixture["sha256"], f"sha mismatch {path}: {sha} != {fixture['sha256']}"
    assert not raw.endswith(b"\n"), f"fixture has trailing newline: {path}"
    print(f"OK {fixture['file']} {sha}")
