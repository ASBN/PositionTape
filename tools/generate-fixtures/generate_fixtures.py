from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "conformance"))

from position_tape_reference import FIXTURE_LENGTHS, MARKER_COMPLETE_LENGTHS, generate, generate_marker_complete

MANIFEST_RULE = (
    "1-indexed positions; non-multiples of 10 emit last digit; multiples of 10 emit decimal p/10; "
    "multi-char markers advance cursor by marker length; final exact length may truncate marker."
)


def write_fixture(path: Path, text: str) -> None:
    path.write_bytes(text.encode("utf-8"))


def manifest_entry(path: Path) -> dict[str, object]:
    raw = path.read_bytes()
    text = raw.decode("utf-8")
    return {
        "file": path.name,
        "bytes": len(raw),
        "sha256": hashlib.sha256(raw).hexdigest(),
        "first_50": text[:50],
        "last_50": text[-50:],
    }


if __name__ == "__main__":
    root = Path(__file__).resolve().parents[2]
    fixtures = root / "fixtures"
    fixtures.mkdir(exist_ok=True)

    for length in FIXTURE_LENGTHS:
        write_fixture(fixtures / f"position_tape_{length}.txt", generate(length))

    for length in MARKER_COMPLETE_LENGTHS:
        write_fixture(
            fixtures / f"position_tape_{length}_marker_complete.txt",
            generate_marker_complete(length),
        )

    manifest = {
        "name": "PositionTape official bootstrap fixtures",
        "encoding": "utf-8",
        "newline": "none",
        "rule": MANIFEST_RULE,
        "fixtures": [manifest_entry(path) for path in sorted(fixtures.glob("position_tape_*.txt"))],
    }
    (fixtures / "manifest.generated.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
