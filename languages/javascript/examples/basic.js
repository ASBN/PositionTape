"use strict";

const { Generate, GenerateMarkerComplete, Validate } = require("../src/position-tape");

const exact = Generate(100);
const markerComplete = GenerateMarkerComplete(1000);
const validation = Validate(exact, 100);

console.log(exact);
console.log(markerComplete.length);
console.log(validation.isValid);
