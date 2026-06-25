import 'dart:convert';

const int defaultSearchLength = 100003;
final Map<int, Map<String, List<int>>> _indexCache = {};

class Mismatch {
  const Mismatch(this.position, this.expected, this.received);

  final int position;
  final String? expected;
  final String? received;
}

class ValidationResult {
  const ValidationResult(
    this.isValid,
    this.expectedLength,
    this.receivedLength,
    this.truncationPoint,
    this.firstMismatch,
  );

  final bool isValid;
  final int expectedLength;
  final int receivedLength;
  final int? truncationPoint;
  final Mismatch? firstMismatch;
}

void _assertNonNegative(int length) {
  if (length < 0) {
    throw ArgumentError.value(length, 'length', 'must be non-negative');
  }
}

String Generate(int length) {
  _assertNonNegative(length);
  final output = StringBuffer();
  var cursor = 1;

  while (output.length < length) {
    if (cursor % 10 == 0) {
      final marker = (cursor ~/ 10).toString();
      final remaining = length - output.length;
      output.write(marker.substring(0, remaining < marker.length ? remaining : marker.length));
      cursor += marker.length;
    } else {
      output.write(cursor % 10);
      cursor += 1;
    }
  }

  return output.toString();
}

int GetMarkerCompleteLength(int length) {
  _assertNonNegative(length);
  var cursor = 1;

  while (cursor <= length) {
    if (cursor % 10 == 0) {
      final markerLength = (cursor ~/ 10).toString().length;
      final markerEnd = cursor + markerLength - 1;
      if (length < markerEnd) {
        return markerEnd;
      }
      cursor += markerLength;
    } else {
      cursor += 1;
    }
  }

  return length;
}

String GenerateMarkerComplete(int length) => Generate(GetMarkerCompleteLength(length));

Mismatch? FindFirstMismatch(String expected, String received) {
  final sharedLength = expected.length < received.length ? expected.length : received.length;
  for (var index = 0; index < sharedLength; index += 1) {
    if (expected[index] != received[index]) {
      return Mismatch(index + 1, expected[index], received[index]);
    }
  }

  if (expected.length == received.length) {
    return null;
  }

  final position = sharedLength + 1;
  return Mismatch(
    position,
    position <= expected.length ? expected[position - 1] : null,
    position <= received.length ? received[position - 1] : null,
  );
}

ValidationResult Validate(String receivedText, int expectedLength) {
  final expected = Generate(expectedLength);
  final mismatch = FindFirstMismatch(expected, receivedText);
  int? truncationPoint;
  if (mismatch != null && receivedText.length < expectedLength && expected.startsWith(receivedText)) {
    truncationPoint = receivedText.length + 1;
  }

  return ValidationResult(
    mismatch == null,
    expectedLength,
    receivedText.length,
    truncationPoint,
    mismatch,
  );
}

int FindTruncationPoint(String receivedText) {
  final mismatch = FindFirstMismatch(Generate(receivedText.length), receivedText);
  return mismatch == null ? receivedText.length + 1 : mismatch.position;
}

int Locate(String fragment) {
  if (fragment.isEmpty) {
    return 1;
  }
  final index = Generate(defaultSearchLength).indexOf(fragment);
  return index < 0 ? -1 : index + 1;
}

int _rotr(int value, int count) {
  value &= 0xffffffff;
  return ((value >> count) | (value << (32 - count))) & 0xffffffff;
}

const List<int> _k = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

String HashFragment(String fragment) {
  final message = utf8.encode(fragment);
  final bitLength = message.length * 8;
  final padded = <int>[...message, 0x80];
  while (padded.length % 64 != 56) {
    padded.add(0);
  }
  for (var shift = 56; shift >= 0; shift -= 8) {
    padded.add((bitLength >> shift) & 0xff);
  }

  var h0 = 0x6a09e667;
  var h1 = 0xbb67ae85;
  var h2 = 0x3c6ef372;
  var h3 = 0xa54ff53a;
  var h4 = 0x510e527f;
  var h5 = 0x9b05688c;
  var h6 = 0x1f83d9ab;
  var h7 = 0x5be0cd19;

  for (var chunk = 0; chunk < padded.length; chunk += 64) {
    final w = List<int>.filled(64, 0);
    for (var index = 0; index < 16; index += 1) {
      final base = chunk + index * 4;
      w[index] = ((padded[base] << 24) | (padded[base + 1] << 16) | (padded[base + 2] << 8) | padded[base + 3]) & 0xffffffff;
    }
    for (var index = 16; index < 64; index += 1) {
      final s0 = _rotr(w[index - 15], 7) ^ _rotr(w[index - 15], 18) ^ (w[index - 15] >> 3);
      final s1 = _rotr(w[index - 2], 17) ^ _rotr(w[index - 2], 19) ^ (w[index - 2] >> 10);
      w[index] = (w[index - 16] + s0 + w[index - 7] + s1) & 0xffffffff;
    }

    var a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;
    for (var index = 0; index < 64; index += 1) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ ((~e) & g);
      final temp1 = (h + s1 + ch + _k[index] + w[index]) & 0xffffffff;
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (s0 + maj) & 0xffffffff;
      h = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xffffffff;
    }

    h0 = (h0 + a) & 0xffffffff;
    h1 = (h1 + b) & 0xffffffff;
    h2 = (h2 + c) & 0xffffffff;
    h3 = (h3 + d) & 0xffffffff;
    h4 = (h4 + e) & 0xffffffff;
    h5 = (h5 + f) & 0xffffffff;
    h6 = (h6 + g) & 0xffffffff;
    h7 = (h7 + h) & 0xffffffff;
  }

  return [h0, h1, h2, h3, h4, h5, h6, h7].map((value) => value.toRadixString(16).padLeft(8, '0')).join();
}

Map<String, List<int>> BuildWindowIndex(int windowSize) {
  if (windowSize <= 0) {
    throw ArgumentError.value(windowSize, 'windowSize', 'must be positive');
  }
  if (windowSize > defaultSearchLength) {
    throw ArgumentError.value(windowSize, 'windowSize', 'cannot exceed the default search length');
  }

  final tape = Generate(defaultSearchLength);
  final index = <String, List<int>>{};
  for (var offset = 0; offset <= tape.length - windowSize; offset += 1) {
    final hash = HashFragment(tape.substring(offset, offset + windowSize));
    index.putIfAbsent(hash, () => <int>[]).add(offset + 1);
  }
  return index;
}

List<int> LocateByHash(String fragmentHash, int windowSize) {
  final normalizedHash = fragmentHash.trim().toLowerCase();
  final index = _indexCache.putIfAbsent(windowSize, () => BuildWindowIndex(windowSize));
  return List<int>.from(index[normalizedHash] ?? const <int>[]);
}
