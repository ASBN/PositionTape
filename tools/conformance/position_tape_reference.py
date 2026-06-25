from __future__ import annotations

import re

FIXTURE_LENGTHS = [0, 1, 9, 10, 11, 99, 100, 101, 150, 1000, 10000]
MARKER_COMPLETE_LENGTHS = [10000]


def generate(length: int) -> str:
    if length < 0:
        raise ValueError("length must be non-negative")

    output: list[str] = []
    cursor = 1
    remaining = length

    while remaining > 0:
        if cursor % 10 == 0:
            marker = str(cursor // 10)
            output.append(marker[:remaining])
            remaining -= min(len(marker), remaining)
            cursor += len(marker)
        else:
            output.append(str(cursor % 10))
            remaining -= 1
            cursor += 1

    return "".join(output)


def marker_complete_length(length: int) -> int:
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


def generate_marker_complete(length: int) -> str:
    return generate(marker_complete_length(length))


def expected_fixture_content(file_name: str) -> str:
    marker_complete_match = re.fullmatch(r"position_tape_(\d+)_marker_complete\.txt", file_name)
    if marker_complete_match:
        return generate_marker_complete(int(marker_complete_match.group(1)))

    exact_match = re.fullmatch(r"position_tape_(\d+)\.txt", file_name)
    if exact_match:
        return generate(int(exact_match.group(1)))

    raise ValueError(f"Unsupported fixture file name: {file_name}")
