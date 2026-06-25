from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

from position_tape_reference import expected_fixture_content

UTF8_BOM = b"\xef\xbb\xbf"


class ConformanceError(Exception):
    pass


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def verify_fixture(root: Path, fixture: dict[str, object]) -> None:
    file_name = str(fixture["file"])
    path = root / "fixtures" / file_name
    if not path.exists():
        raise ConformanceError(f"missing fixture: {path}")

    raw = path.read_bytes()
    expected_text = expected_fixture_content(file_name)
    expected_raw = expected_text.encode("utf-8")
    actual_sha = sha256_hex(raw)

    if raw.startswith(UTF8_BOM):
        raise ConformanceError(f"fixture has UTF-8 BOM: {file_name}")
    if raw.endswith(b"\n") or raw.endswith(b"\r"):
        raise ConformanceError(f"fixture has trailing newline: {file_name}")
    if raw != expected_raw:
        raise ConformanceError(f"fixture content does not match reference generator: {file_name}")
    if len(raw) != int(fixture["bytes"]):
        raise ConformanceError(f"length mismatch {file_name}: {len(raw)} != {fixture['bytes']}")
    if actual_sha != str(fixture["sha256"]):
        raise ConformanceError(f"sha mismatch {file_name}: {actual_sha} != {fixture['sha256']}")

    first_50 = fixture.get("first_50")
    if first_50 is not None and expected_text[:50] != first_50:
        raise ConformanceError(f"first_50 mismatch: {file_name}")

    last_50 = fixture.get("last_50")
    if last_50 is not None and expected_text[-50:] != last_50:
        raise ConformanceError(f"last_50 mismatch: {file_name}")

    print(f"OK {file_name} {actual_sha}")


def verify_manifest(manifest_path: Path) -> None:
    root = manifest_path.resolve().parents[1]
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

    if manifest.get("encoding") != "utf-8":
        raise ConformanceError("manifest encoding must be utf-8")
    if manifest.get("newline") != "none":
        raise ConformanceError("manifest newline must be none")

    fixtures = manifest.get("fixtures")
    if not isinstance(fixtures, list) or not fixtures:
        raise ConformanceError("manifest must contain at least one fixture")

    for fixture in fixtures:
        if not isinstance(fixture, dict):
            raise ConformanceError("fixture entry must be an object")
        verify_fixture(root, fixture)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Run PositionTape fixture conformance checks.")
    parser.add_argument(
        "--manifest",
        type=Path,
        default=Path(__file__).resolve().parents[2] / "fixtures" / "manifest.generated.json",
        help="Path to fixtures/manifest.generated.json.",
    )
    args = parser.parse_args(argv)

    try:
        verify_manifest(args.manifest)
    except ConformanceError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
