from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from typing import Dict, List, Optional


DEFAULT_SEARCH_LENGTH = 100_003
_INDEX_CACHE: dict[int, dict[str, list[int]]] = {}


@dataclass(frozen=True)
class Mismatch:
    position: int
    expected: Optional[str]
    received: Optional[str]


@dataclass(frozen=True)
class ValidationResult:
    is_valid: bool
    expected_length: int
    received_length: int
    truncation_point: Optional[int]
    first_mismatch: Optional[Mismatch]


def Generate(length: int) -> str:
    if length < 0:
        raise ValueError("length must be non-negative")

    output: list[str] = []
    cursor = 1
    remaining = length

    while remaining > 0:
        if cursor % 10 == 0:
            marker = str(cursor // 10)
            chunk = marker[:remaining]
            output.append(chunk)
            remaining -= len(chunk)
            cursor += len(marker)
        else:
            output.append(str(cursor % 10))
            remaining -= 1
            cursor += 1

    return "".join(output)


def GenerateMarkerComplete(length: int) -> str:
    return Generate(GetMarkerCompleteLength(length))


def GetMarkerCompleteLength(length: int) -> int:
    if length < 0:
        raise ValueError("length must be non-negative")

    cursor = 1
    while cursor <= length:
        if cursor % 10 == 0:
            marker_length = len(str(cursor // 10))
            marker_end = cursor + marker_length - 1
            if length < marker_end:
                return marker_end
            cursor += marker_length
        else:
            cursor += 1

    return length


def Locate(fragment: str) -> int:
    if fragment == "":
        return 1

    index = Generate(DEFAULT_SEARCH_LENGTH).find(fragment)
    return -1 if index < 0 else index + 1


def Validate(receivedText: str, expectedLength: int) -> ValidationResult:
    expected = Generate(expectedLength)
    mismatch = FindFirstMismatch(expected, receivedText)
    truncation_point: Optional[int] = None

    if mismatch is not None and len(receivedText) < expectedLength and expected.startswith(receivedText):
        truncation_point = len(receivedText) + 1

    return ValidationResult(
        is_valid=mismatch is None,
        expected_length=expectedLength,
        received_length=len(receivedText),
        truncation_point=truncation_point,
        first_mismatch=mismatch,
    )


def FindTruncationPoint(receivedText: str) -> int:
    expected_prefix = Generate(len(receivedText))
    mismatch = FindFirstMismatch(expected_prefix, receivedText)
    return mismatch.position if mismatch is not None else len(receivedText) + 1


def FindFirstMismatch(expected: str, received: str) -> Optional[Mismatch]:
    shared_length = min(len(expected), len(received))

    for index in range(shared_length):
        if expected[index] != received[index]:
            return Mismatch(index + 1, expected[index], received[index])

    if len(expected) == len(received):
        return None

    position = shared_length + 1
    expected_char = expected[position - 1] if position <= len(expected) else None
    received_char = received[position - 1] if position <= len(received) else None
    return Mismatch(position, expected_char, received_char)


def HashFragment(fragment: str) -> str:
    return sha256(fragment.encode("utf-8")).hexdigest()


def BuildWindowIndex(windowSize: int) -> Dict[str, List[int]]:
    if windowSize <= 0:
        raise ValueError("windowSize must be positive")
    if windowSize > DEFAULT_SEARCH_LENGTH:
        raise ValueError("windowSize cannot exceed the default search length")

    tape = Generate(DEFAULT_SEARCH_LENGTH)
    index: dict[str, list[int]] = {}

    for offset in range(0, len(tape) - windowSize + 1):
        fragment_hash = HashFragment(tape[offset : offset + windowSize])
        index.setdefault(fragment_hash, []).append(offset + 1)

    return index


def LocateByHash(fragmentHash: str, windowSize: int) -> List[int]:
    normalized_hash = fragmentHash.strip().lower()
    if windowSize not in _INDEX_CACHE:
        _INDEX_CACHE[windowSize] = BuildWindowIndex(windowSize)
    return list(_INDEX_CACHE[windowSize].get(normalized_hash, []))


generate = Generate
generate_marker_complete = GenerateMarkerComplete
get_marker_complete_length = GetMarkerCompleteLength
locate = Locate
validate = Validate
find_truncation_point = FindTruncationPoint
find_first_mismatch = FindFirstMismatch
hash_fragment = HashFragment
build_window_index = BuildWindowIndex
locate_by_hash = LocateByHash
