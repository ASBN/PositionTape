"use strict";

const crypto = require("node:crypto");

const DEFAULT_SEARCH_LENGTH = 100_003;
const indexCache = new Map();

class Mismatch {
  constructor(position, expected, received) {
    this.position = position;
    this.expected = expected;
    this.received = received;
  }
}

class ValidationResult {
  constructor(isValid, expectedLength, receivedLength, truncationPoint, firstMismatch) {
    this.isValid = isValid;
    this.expectedLength = expectedLength;
    this.receivedLength = receivedLength;
    this.truncationPoint = truncationPoint;
    this.firstMismatch = firstMismatch;
  }
}

function assertNonNegativeLength(length, name) {
  if (!Number.isInteger(length) || length < 0) {
    throw new RangeError(`${name} must be a non-negative integer`);
  }
}

function Generate(length) {
  assertNonNegativeLength(length, "length");

  const output = [];
  let cursor = 1;
  let remaining = length;

  while (remaining > 0) {
    if (cursor % 10 === 0) {
      const marker = String(cursor / 10);
      const chunk = marker.slice(0, remaining);
      output.push(chunk);
      remaining -= chunk.length;
      cursor += marker.length;
    } else {
      output.push(String(cursor % 10));
      remaining -= 1;
      cursor += 1;
    }
  }

  return output.join("");
}

function GetMarkerCompleteLength(length) {
  assertNonNegativeLength(length, "length");

  let cursor = 1;
  while (cursor <= length) {
    if (cursor % 10 === 0) {
      const markerLength = String(cursor / 10).length;
      const markerEnd = cursor + markerLength - 1;
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

function GenerateMarkerComplete(length) {
  return Generate(GetMarkerCompleteLength(length));
}

function Locate(fragment) {
  if (fragment === "") {
    return 1;
  }

  const index = Generate(DEFAULT_SEARCH_LENGTH).indexOf(fragment);
  return index < 0 ? -1 : index + 1;
}

function FindFirstMismatch(expected, received) {
  const sharedLength = Math.min(expected.length, received.length);

  for (let index = 0; index < sharedLength; index += 1) {
    if (expected[index] !== received[index]) {
      return new Mismatch(index + 1, expected[index], received[index]);
    }
  }

  if (expected.length === received.length) {
    return null;
  }

  const position = sharedLength + 1;
  return new Mismatch(
    position,
    position <= expected.length ? expected[position - 1] : null,
    position <= received.length ? received[position - 1] : null,
  );
}

function Validate(receivedText, expectedLength) {
  const expected = Generate(expectedLength);
  const mismatch = FindFirstMismatch(expected, receivedText);
  let truncationPoint = null;

  if (mismatch !== null && receivedText.length < expectedLength && expected.startsWith(receivedText)) {
    truncationPoint = receivedText.length + 1;
  }

  return new ValidationResult(
    mismatch === null,
    expectedLength,
    receivedText.length,
    truncationPoint,
    mismatch,
  );
}

function FindTruncationPoint(receivedText) {
  const expectedPrefix = Generate(receivedText.length);
  const mismatch = FindFirstMismatch(expectedPrefix, receivedText);
  return mismatch === null ? receivedText.length + 1 : mismatch.position;
}

function HashFragment(fragment) {
  return crypto.createHash("sha256").update(fragment, "utf8").digest("hex");
}

function BuildWindowIndex(windowSize) {
  if (!Number.isInteger(windowSize) || windowSize <= 0) {
    throw new RangeError("windowSize must be a positive integer");
  }
  if (windowSize > DEFAULT_SEARCH_LENGTH) {
    throw new RangeError("windowSize cannot exceed the default search length");
  }

  const tape = Generate(DEFAULT_SEARCH_LENGTH);
  const index = new Map();
  for (let offset = 0; offset <= tape.length - windowSize; offset += 1) {
    const hash = HashFragment(tape.slice(offset, offset + windowSize));
    if (!index.has(hash)) {
      index.set(hash, []);
    }
    index.get(hash).push(offset + 1);
  }
  return index;
}

function LocateByHash(fragmentHash, windowSize) {
  const normalizedHash = fragmentHash.trim().toLowerCase();
  if (!indexCache.has(windowSize)) {
    indexCache.set(windowSize, BuildWindowIndex(windowSize));
  }
  return [...(indexCache.get(windowSize).get(normalizedHash) || [])];
}

module.exports = {
  DEFAULT_SEARCH_LENGTH,
  BuildWindowIndex,
  FindFirstMismatch,
  FindTruncationPoint,
  Generate,
  GenerateMarkerComplete,
  GetMarkerCompleteLength,
  HashFragment,
  Locate,
  LocateByHash,
  Mismatch,
  Validate,
  ValidationResult,
};
