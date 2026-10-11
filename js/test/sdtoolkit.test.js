import { test } from "node:test";
import assert from "node:assert/strict";
import * as sd from "../index.js";

const classic = [2, 4, 4, 4, 5, 5, 7, 9];
const offset = [1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16];
const close = (a, b) => assert.ok(Math.abs(a - b) <= 1e-12 * Math.abs(b), `${a} != ${b}`);

test("classic dataset", () => {
  assert.equal(sd.mean(classic), 5);
  assert.equal(sd.sumOfSquares(classic), 32);
  assert.equal(sd.populationVariance(classic), 4);
  assert.equal(sd.populationStdev(classic), 2);
  close(sd.sampleVariance(classic), 32 / 7);
  close(sd.sampleStdev(classic), 2.138089935299395);
  close(sd.relativeStdDev(classic), 42.7617987059879);
  assert.equal(sd.relativeStdDev(classic, { population: true }), 40);
  close(sd.coefficientOfVariation(classic), 2.138089935299395 / 5);
});

test("large offset is exact", () => {
  assert.equal(sd.sumOfSquares(offset), 90);
  assert.equal(sd.sampleVariance(offset), 30);
});

test("negative mean uses |mean|", () => {
  assert.equal(
    sd.relativeStdDev([-2, -4, -6], { population: true }),
    sd.relativeStdDev([2, 4, 6], { population: true }),
  );
});

test("single value", () => {
  assert.equal(sd.populationVariance([7]), 0);
  assert.equal(sd.populationStdev([7]), 0);
  for (const fn of [sd.sampleVariance, sd.sampleStdev, sd.relativeStdDev, sd.describe]) {
    assert.throws(() => fn([5]), /at least 2/);
  }
});

test("zero mean", () => {
  assert.throws(() => sd.relativeStdDev([-1, 1]), /mean is zero/);
  assert.throws(() => sd.coefficientOfVariation([-2, 0, 2], { population: true }), /mean is zero/);
  assert.equal(sd.describe([-1, 1]).rsdPercent, null);
});

test("describe", () => {
  assert.deepEqual(sd.describe(classic, { population: true }), {
    n: 8, mean: 5, minimum: 2, maximum: 9, range: 7, sumOfSquares: 32,
    variance: 4, stdev: 2, rsdPercent: 40, population: true,
  });
  assert.equal(sd.describe([1, 2]).population, false);
});

test("iterables", () => {
  assert.equal(sd.mean(new Set([1, 2, 3])), 2);
  assert.equal(sd.mean(Float64Array.of(1, 2, 3)), 2);
});

test("invalid input", () => {
  assert.throws(() => sd.mean([]), sd.StatisticsError);
  assert.throws(() => sd.mean([]), /no data points/);
  const cases = [
    [[1, NaN], /NaN/],
    [[1, Infinity], /infinity/],
    [[1, -Infinity], /infinity/],
    [[1, null], /item 1: null/],
    [[1, undefined], /missing value/],
    [[1, true], /booleans/],
    [[1, "2"], /strings/],
    [[1, 2n], /not a number/],
  ];
  for (const [data, re] of cases) assert.throws(() => sd.mean(data), re);
  assert.throws(() => sd.mean("123"), /iterable/);
  assert.throws(() => sd.mean(42), /iterable/);
});
