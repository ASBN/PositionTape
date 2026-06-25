<?php

declare(strict_types=1);

require __DIR__ . '/../src/PositionTape.php';

use function PositionTape\Generate;
use function PositionTape\GenerateMarkerComplete;
use function PositionTape\Validate;

$exact = Generate(100);
$markerComplete = GenerateMarkerComplete(1000);
$validation = Validate($exact, 100);

echo $exact . PHP_EOL;
echo strlen($markerComplete) . PHP_EOL;
echo ($validation->isValid ? 'true' : 'false') . PHP_EOL;
