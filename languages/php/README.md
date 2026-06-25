# PositionTape for php

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```php
require 'src/PositionTape.php';

$exact = PositionTape\Generate(10000);
$markerComplete = PositionTape\GenerateMarkerComplete(10000);
$validation = PositionTape\Validate($exact, 10000);
```

## Verify

```powershell
php .\languages\php\tests\position_tape_test.php
```
