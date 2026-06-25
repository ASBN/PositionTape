<?php

declare(strict_types=1);

namespace PositionTape;

const DEFAULT_SEARCH_LENGTH = 100003;

final class Mismatch
{
    public function __construct(
        public int $position,
        public ?string $expected,
        public ?string $received
    ) {
    }
}

final class ValidationResult
{
    public function __construct(
        public bool $isValid,
        public int $expectedLength,
        public int $receivedLength,
        public ?int $truncationPoint,
        public ?Mismatch $firstMismatch
    ) {
    }
}

function assertNonNegativeLength(int $length): void
{
    if ($length < 0) {
        throw new \InvalidArgumentException('length must be non-negative');
    }
}

function Generate(int $length): string
{
    assertNonNegativeLength($length);
    $output = '';
    $cursor = 1;

    while (strlen($output) < $length) {
        if ($cursor % 10 === 0) {
            $marker = (string) intdiv($cursor, 10);
            $remaining = $length - strlen($output);
            $output .= substr($marker, 0, $remaining);
            $cursor += strlen($marker);
        } else {
            $output .= (string) ($cursor % 10);
            $cursor += 1;
        }
    }

    return $output;
}

function GetMarkerCompleteLength(int $length): int
{
    assertNonNegativeLength($length);
    $cursor = 1;

    while ($cursor <= $length) {
        if ($cursor % 10 === 0) {
            $markerLength = strlen((string) intdiv($cursor, 10));
            $markerEnd = $cursor + $markerLength - 1;
            if ($length < $markerEnd) {
                return $markerEnd;
            }
            $cursor += $markerLength;
        } else {
            $cursor += 1;
        }
    }

    return $length;
}

function GenerateMarkerComplete(int $length): string
{
    return Generate(GetMarkerCompleteLength($length));
}

function FindFirstMismatch(string $expected, string $received): ?Mismatch
{
    $sharedLength = min(strlen($expected), strlen($received));
    for ($index = 0; $index < $sharedLength; $index += 1) {
        if ($expected[$index] !== $received[$index]) {
            return new Mismatch($index + 1, $expected[$index], $received[$index]);
        }
    }

    if (strlen($expected) === strlen($received)) {
        return null;
    }

    $position = $sharedLength + 1;
    return new Mismatch(
        $position,
        $position <= strlen($expected) ? $expected[$position - 1] : null,
        $position <= strlen($received) ? $received[$position - 1] : null
    );
}

function Validate(string $receivedText, int $expectedLength): ValidationResult
{
    $expected = Generate($expectedLength);
    $mismatch = FindFirstMismatch($expected, $receivedText);
    $truncationPoint = null;

    if ($mismatch !== null && strlen($receivedText) < $expectedLength && str_starts_with($expected, $receivedText)) {
        $truncationPoint = strlen($receivedText) + 1;
    }

    return new ValidationResult(
        $mismatch === null,
        $expectedLength,
        strlen($receivedText),
        $truncationPoint,
        $mismatch
    );
}

function FindTruncationPoint(string $receivedText): int
{
    $mismatch = FindFirstMismatch(Generate(strlen($receivedText)), $receivedText);
    return $mismatch === null ? strlen($receivedText) + 1 : $mismatch->position;
}

function Locate(string $fragment): int
{
    if ($fragment === '') {
        return 1;
    }

    $index = strpos(Generate(DEFAULT_SEARCH_LENGTH), $fragment);
    return $index === false ? -1 : $index + 1;
}

function HashFragment(string $fragment): string
{
    return hash('sha256', $fragment);
}

function BuildWindowIndex(int $windowSize): array
{
    if ($windowSize <= 0) {
        throw new \InvalidArgumentException('windowSize must be positive');
    }
    if ($windowSize > DEFAULT_SEARCH_LENGTH) {
        throw new \InvalidArgumentException('windowSize cannot exceed the default search length');
    }

    $tape = Generate(DEFAULT_SEARCH_LENGTH);
    $index = [];
    for ($offset = 0; $offset <= strlen($tape) - $windowSize; $offset += 1) {
        $hash = HashFragment(substr($tape, $offset, $windowSize));
        $index[$hash][] = $offset + 1;
    }
    return $index;
}

function LocateByHash(string $fragmentHash, int $windowSize): array
{
    static $cache = [];
    $normalizedHash = strtolower(trim($fragmentHash));
    if (!array_key_exists($windowSize, $cache)) {
        $cache[$windowSize] = BuildWindowIndex($windowSize);
    }
    return $cache[$windowSize][$normalizedHash] ?? [];
}
