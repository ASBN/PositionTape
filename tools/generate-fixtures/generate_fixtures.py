from __future__ import annotations
import hashlib
import json
from pathlib import Path

def generate(length: int) -> str:
    if length < 0:
        raise ValueError("length must be non-negative")
    out: list[str] = []
    p = 1
    remaining = length
    while remaining > 0:
        if p % 10 == 0:
            marker = str(p // 10)
            out.append(marker[:remaining])
            remaining -= min(len(marker), remaining)
            p += len(marker)
        else:
            out.append(str(p % 10))
            remaining -= 1
            p += 1
    return "".join(out)

def marker_complete_length(length: int) -> int:
    if length < 0:
        raise ValueError("length must be non-negative")
    p = 1
    while p <= length:
        if p % 10 == 0:
            marker_len = len(str(p // 10))
            marker_end = p + marker_len - 1
            if p <= length < marker_end:
                return marker_end
            p += marker_len
        else:
            p += 1
    return length

def generate_marker_complete(length: int) -> str:
    return generate(marker_complete_length(length))

if __name__ == "__main__":
    root = Path(__file__).resolve().parents[2]
    fixtures = root / "fixtures"
    fixtures.mkdir(exist_ok=True)
    lengths = [0, 1, 9, 10, 11, 99, 100, 101, 150, 1000, 10000]
    for n in lengths:
        (fixtures / f"position_tape_{n}.txt").write_text(generate(n), encoding="utf-8", newline="")
    (fixtures / "position_tape_10000_marker_complete.txt").write_text(generate_marker_complete(10000), encoding="utf-8", newline="")
    manifest = {"fixtures": []}
    for file in sorted(fixtures.glob("position_tape_*.txt")):
        raw = file.read_bytes()
        manifest["fixtures"].append({"file": file.name, "bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()})
    (fixtures / "manifest.generated.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
