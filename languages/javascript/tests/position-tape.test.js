"use strict";

const assert = require("node:assert/strict");
const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");

const tape = require("../src/position-tape");

const root = path.resolve(__dirname, "..", "..", "..");

function test(name, fn) {
  try {
    fn();
    console.log(`OK ${name}`);
  } catch (error) {
    console.error(`FAIL ${name}`);
    throw error;
  }
}

test("generates known exact lengths", () => {
  assert.equal(tape.Generate(0), "");
  assert.equal(tape.Generate(10), "1234567891");
  assert.equal(tape.Generate(20), "12345678911234567892");
  assert.equal(tape.Generate(100).length, 100);
});

test("generates marker-complete output", () => {
  assert.equal(tape.GenerateMarkerComplete(99), tape.Generate(99));
  assert.equal(tape.GenerateMarkerComplete(100), tape.Generate(101));
  assert.equal(tape.GenerateMarkerComplete(1000).length, 1002);
  assert.equal(tape.GenerateMarkerComplete(10000).length, 10003);
});

test("validates and reports mismatch diagnostics", () => {
  const expected = tape.Generate(50);
  assert.equal(tape.Validate(expected, 50).isValid, true);

  const truncated = tape.Validate(expected.slice(0, 17), 50);
  assert.equal(truncated.isValid, false);
  assert.equal(truncated.truncationPoint, 18);
  assert.equal(truncated.firstMismatch.position, 18);

  const mutated = `${expected.slice(0, 12)}X${expected.slice(13)}`;
  const mismatch = tape.FindFirstMismatch(expected, mutated);
  assert.equal(mismatch.position, 13);
  assert.equal(mismatch.expected, expected[12]);
  assert.equal(mismatch.received, "X");
});

test("finds truncation point", () => {
  assert.equal(tape.FindTruncationPoint(tape.Generate(20)), 21);
  assert.equal(tape.FindTruncationPoint("123X"), 4);
});

test("locates directly and by hash", () => {
  const fragment = tape.Generate(80).slice(29, 41);
  assert.equal(tape.Locate(fragment), 30);

  const hash = tape.HashFragment(fragment);
  const index = tape.BuildWindowIndex(fragment.length);
  assert.equal(index.get(hash).includes(30), true);
  assert.equal(tape.LocateByHash(hash.toUpperCase(), fragment.length).includes(30), true);
});

test("matches official manifest fixtures", () => {
  const manifest = JSON.parse(fs.readFileSync(path.join(root, "fixtures", "manifest.generated.json"), "utf8"));

  for (const fixture of manifest.fixtures) {
    const raw = fs.readFileSync(path.join(root, "fixtures", fixture.file));
    assert.equal(raw.subarray(0, 3).equals(Buffer.from([0xef, 0xbb, 0xbf])), false, fixture.file);
    assert.equal(raw.at(-1) === 0x0a || raw.at(-1) === 0x0d, false, fixture.file);
    assert.equal(raw.length, fixture.bytes, fixture.file);
    assert.equal(crypto.createHash("sha256").update(raw).digest("hex"), fixture.sha256, fixture.file);

    const text = raw.toString("utf8");
    const exact = fixture.file.match(/^position_tape_(\d+)\.txt$/);
    const markerComplete = fixture.file.match(/^position_tape_(\d+)_marker_complete\.txt$/);
    const expected = exact
      ? tape.Generate(Number(exact[1]))
      : tape.GenerateMarkerComplete(Number(markerComplete[1]));

    assert.equal(text, expected, fixture.file);
  }
});
