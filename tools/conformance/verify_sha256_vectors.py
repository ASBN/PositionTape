from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any

SHA256_HEX_PATTERN = re.compile(r"^[0-9a-f]{64}$")


class VectorVerificationError(Exception):
    """Raised when a shared SHA-256 vector is malformed or incorrect."""


def sha256_hex(text: str) -> str:
    """Return lowercase SHA-256 hex for the UTF-8 bytes of text."""

    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def verify_vector(vector: dict[str, Any]) -> None:
    """Verify one vector object from fixtures/sha256-vectors.json."""

    name = str(vector.get("name", "<unnamed>"))
    input_text = vector.get("input")
    expected = vector.get("sha256")

    if not isinstance(input_text, str):
        raise VectorVerificationError(f"{name}: input must be a string")
    if not isinstance(expected, str) or not SHA256_HEX_PATTERN.fullmatch(expected):
        raise VectorVerificationError(f"{name}: sha256 must be lowercase 64-character hex")

    actual = sha256_hex(input_text)
    if actual != expected:
        raise VectorVerificationError(f"{name}: {actual} != {expected}")

    print(f"OK {name} {actual}")


def verify_vectors(path: Path) -> None:
    """Load and verify the shared SHA-256 vector file."""

    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("algorithm") != "SHA-256":
        raise VectorVerificationError("algorithm must be SHA-256")
    if data.get("encoding") != "utf-8":
        raise VectorVerificationError("encoding must be utf-8")
    if data.get("format") != "lowercase-hex":
        raise VectorVerificationError("format must be lowercase-hex")

    vectors = data.get("vectors")
    if not isinstance(vectors, list) or not vectors:
        raise VectorVerificationError("vectors must be a non-empty list")

    for vector in vectors:
        if not isinstance(vector, dict):
            raise VectorVerificationError("each vector must be an object")
        verify_vector(vector)


def main(argv: list[str] | None = None) -> int:
    """Run the shared SHA-256 vector sanity check."""

    parser = argparse.ArgumentParser(description="Verify PositionTape shared SHA-256 vectors.")
    parser.add_argument(
        "--vectors",
        type=Path,
        default=Path(__file__).resolve().parents[2] / "fixtures" / "sha256-vectors.json",
        help="Path to fixtures/sha256-vectors.json.",
    )
    args = parser.parse_args(argv)

    try:
        verify_vectors(args.vectors)
    except (OSError, json.JSONDecodeError, VectorVerificationError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
