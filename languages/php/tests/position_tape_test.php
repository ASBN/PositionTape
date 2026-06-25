<?php

declare(strict_types=1);

require __DIR__ . '/../src/PositionTape.php';

use function PositionTape\BuildWindowIndex;
use function PositionTape\FindFirstMismatch;
use function PositionTape\FindTruncationPoint;
use function PositionTape\Generate;
use function PositionTape\GenerateMarkerComplete;
use function PositionTape\HashFragment;
use function PositionTape\Locate;
use function PositionTape\LocateByHash;
use function PositionTape\Validate;

function assertSameValue(mixed $expected, mixed $actual, string $message): void
{
    if ($expected !== $actual) {
        throw new RuntimeException($message . ': got ' . var_export($actual, true) . ', want ' . var_export($expected, true));
    }
}

assertSameValue('', Generate(0), 'Generate(0)');
assertSameValue('1234567891', Generate(10), 'Generate(10)');
assertSameValue(101, strlen(GenerateMarkerComplete(100)), 'GenerateMarkerComplete(100)');
assertSameValue(10003, strlen(GenerateMarkerComplete(10000)), 'GenerateMarkerComplete(10000)');

$expected = Generate(50);
assertSameValue(true, Validate($expected, 50)->isValid, 'valid result');
assertSameValue(18, Validate(substr($expected, 0, 17), 50)->truncationPoint, 'truncation point');
assertSameValue(4, FindTruncationPoint('123X'), 'mismatch point');
assertSameValue(13, FindFirstMismatch($expected, substr($expected, 0, 12) . 'X' . substr($expected, 13))->position, 'mismatch');

$fragment = substr(Generate(80), 29, 12);
$hash = HashFragment($fragment);
assertSameValue(30, Locate($fragment), 'Locate');
if (!in_array(30, BuildWindowIndex(strlen($fragment))[$hash], true)) {
    throw new RuntimeException('BuildWindowIndex missing position 30');
}
if (!in_array(30, LocateByHash(strtoupper($hash), strlen($fragment)), true)) {
    throw new RuntimeException('LocateByHash missing position 30');
}

$manifest = json_decode(file_get_contents(__DIR__ . '/../../../fixtures/manifest.generated.json'), true, flags: JSON_THROW_ON_ERROR);
foreach ($manifest['fixtures'] as $fixture) {
    $raw = file_get_contents(__DIR__ . '/../../../fixtures/' . $fixture['file']);
    assertSameValue($fixture['bytes'], strlen($raw), $fixture['file'] . ' bytes');
    assertSameValue($fixture['sha256'], hash('sha256', $raw), $fixture['file'] . ' sha256');
    if (str_starts_with($raw, "\xef\xbb\xbf") || str_ends_with($raw, "\n") || str_ends_with($raw, "\r")) {
        throw new RuntimeException($fixture['file'] . ' has invalid encoding/newline');
    }
}

echo "OK php position_tape\n";
