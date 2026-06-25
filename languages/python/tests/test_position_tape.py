from __future__ import annotations

import json
import sys
import unittest
from hashlib import sha256
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "languages" / "python" / "src"))

from position_tape import (  # noqa: E402
    BuildWindowIndex,
    FindFirstMismatch,
    FindTruncationPoint,
    Generate,
    GenerateMarkerComplete,
    HashFragment,
    Locate,
    LocateByHash,
    Validate,
)


class PositionTapeTests(unittest.TestCase):
    def test_generate_known_lengths(self) -> None:
        self.assertEqual("", Generate(0))
        self.assertEqual("1234567891", Generate(10))
        self.assertEqual("12345678911234567892", Generate(20))
        self.assertEqual(100, len(Generate(100)))

    def test_marker_complete_extends_only_crossing_marker(self) -> None:
        self.assertEqual(Generate(99), GenerateMarkerComplete(99))
        self.assertEqual(Generate(101), GenerateMarkerComplete(100))
        self.assertEqual(1002, len(GenerateMarkerComplete(1000)))
        self.assertEqual(10003, len(GenerateMarkerComplete(10000)))

    def test_validate_and_mismatch_diagnostics(self) -> None:
        expected = Generate(50)

        valid = Validate(expected, 50)
        self.assertTrue(valid.is_valid)
        self.assertIsNone(valid.first_mismatch)

        truncated = Validate(expected[:17], 50)
        self.assertFalse(truncated.is_valid)
        self.assertEqual(18, truncated.truncation_point)
        self.assertEqual(18, truncated.first_mismatch.position)

        mutated = expected[:12] + "X" + expected[13:]
        mismatch = FindFirstMismatch(expected, mutated)
        self.assertEqual(13, mismatch.position)
        self.assertEqual(expected[12], mismatch.expected)
        self.assertEqual("X", mismatch.received)

    def test_find_truncation_point(self) -> None:
        self.assertEqual(21, FindTruncationPoint(Generate(20)))
        self.assertEqual(4, FindTruncationPoint("123X"))

    def test_locate_and_hash_index(self) -> None:
        fragment = Generate(80)[29:41]
        self.assertEqual(30, Locate(fragment))

        fragment_hash = HashFragment(fragment)
        index = BuildWindowIndex(len(fragment))
        self.assertIn(30, index[fragment_hash])
        self.assertIn(30, LocateByHash(fragment_hash.upper(), len(fragment)))

    def test_manifest_fixtures_match_generator(self) -> None:
        manifest = json.loads((ROOT / "fixtures" / "manifest.generated.json").read_text(encoding="utf-8"))

        for fixture in manifest["fixtures"]:
            path = ROOT / "fixtures" / fixture["file"]
            raw = path.read_bytes()

            self.assertFalse(raw.startswith(b"\xef\xbb\xbf"), fixture["file"])
            self.assertFalse(raw.endswith(b"\n") or raw.endswith(b"\r"), fixture["file"])
            self.assertEqual(fixture["bytes"], len(raw), fixture["file"])
            self.assertEqual(fixture["sha256"], sha256(raw).hexdigest(), fixture["file"])

            if fixture["file"].endswith("_marker_complete.txt"):
                length = int(fixture["file"].removeprefix("position_tape_").removesuffix("_marker_complete.txt"))
                expected = GenerateMarkerComplete(length)
            else:
                length = int(fixture["file"].removeprefix("position_tape_").removesuffix(".txt"))
                expected = Generate(length)

            self.assertEqual(expected.encode("utf-8"), raw, fixture["file"])


if __name__ == "__main__":
    unittest.main()
