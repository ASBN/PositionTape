import 'dart:convert';
import 'dart:io';

import '../src/position_tape.dart' as pt;

void expectEqual(Object? actual, Object? expected, String message) {
  if (actual != expected) {
    throw StateError('$message: got $actual, want $expected');
  }
}

void main() {
  expectEqual(pt.Generate(0), '', 'Generate(0)');
  expectEqual(pt.Generate(10), '1234567891', 'Generate(10)');
  expectEqual(pt.Generate(20), '12345678911234567892', 'Generate(20)');
  expectEqual(pt.Generate(100).length, 100, 'Generate(100) length');

  expectEqual(pt.GenerateMarkerComplete(99), pt.Generate(99), 'marker complete 99');
  expectEqual(pt.GenerateMarkerComplete(100), pt.Generate(101), 'marker complete 100');
  expectEqual(pt.GenerateMarkerComplete(1000).length, 1002, 'marker complete 1000');
  expectEqual(pt.GenerateMarkerComplete(10000).length, 10003, 'marker complete 10000');

  final expected = pt.Generate(50);
  expectEqual(pt.Validate(expected, 50).isValid, true, 'valid result');
  expectEqual(pt.Validate(expected.substring(0, 17), 50).truncationPoint, 18, 'truncation point');
  expectEqual(pt.FindTruncationPoint('123X'), 4, 'mismatch point');
  expectEqual(pt.FindFirstMismatch('${expected.substring(0, 12)}A', '${expected.substring(0, 12)}X')!.position, 13, 'mismatch');

  final fragment = pt.Generate(80).substring(29, 41);
  final hash = pt.HashFragment(fragment);
  expectEqual(pt.Locate(fragment), 30, 'Locate');
  if (!pt.BuildWindowIndex(fragment.length)[hash]!.contains(30)) {
    throw StateError('BuildWindowIndex missing position 30');
  }
  if (!pt.LocateByHash(hash.toUpperCase(), fragment.length).contains(30)) {
    throw StateError('LocateByHash missing position 30');
  }

  final root = Directory.current.path;
  final manifest = File('$root/fixtures/manifest.generated.json').readAsStringSync();
  final fixturePattern = RegExp(r'"file":\s*"([^"]+)".*?"bytes":\s*(\d+).*?"sha256":\s*"([^"]+)"', dotAll: true);
  for (final match in fixturePattern.allMatches(manifest)) {
    final file = match.group(1)!;
    final bytes = int.parse(match.group(2)!);
    final sha = match.group(3)!;
    final raw = File('$root/fixtures/$file').readAsBytesSync();
    expectEqual(raw.length, bytes, '$file bytes');
    expectEqual(pt.HashFragment(utf8.decode(raw)), sha, '$file sha256');
    if (raw.length >= 3 && raw[0] == 0xef && raw[1] == 0xbb && raw[2] == 0xbf) {
      throw StateError('$file has UTF-8 BOM');
    }
    if (raw.isNotEmpty && (raw.last == 0x0a || raw.last == 0x0d)) {
      throw StateError('$file has trailing newline');
    }
  }

  print('OK dart position_tape');
}
