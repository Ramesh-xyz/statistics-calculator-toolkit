// Dispersion statistics: mean, variance, standard deviation, RSD and CV.
// Corrected two-pass algorithm with Neumaier-compensated sums; see README.

export class StatisticsError extends Error {
  constructor(message) {
    super(message);
    this.name = "StatisticsError";
  }
}

function toNumbers(data) {
  if (typeof data === "string" || data == null || typeof data[Symbol.iterator] !== "function") {
    throw new StatisticsError("expected an array or iterable of numbers");
  }
  const values = [];
  let i = 0;
  for (const x of data) {
    if (x === null || x === undefined) {
      throw new StatisticsError(`item ${i}: ${x} (missing value); remove or fill it before computing`);
    }
    if (typeof x === "boolean") throw new StatisticsError(`item ${i}: booleans are not numbers (${x})`);
    if (typeof x === "string") {
      throw new StatisticsError(`item ${i}: strings are not accepted (${JSON.stringify(x)}); convert with Number() first`);
    }
    if (typeof x !== "number") throw new StatisticsError(`item ${i}: ${String(x)} is not a number`);
    if (Number.isNaN(x)) throw new StatisticsError(`item ${i}: NaN is not allowed`);
    if (!Number.isFinite(x)) throw new StatisticsError(`item ${i}: infinity is not allowed`);
    values.push(x);
    i++;
  }
  if (values.length === 0) throw new StatisticsError("no data points: at least one value is required");
  return values;
}

// Neumaier compensated summation.
function sum(values) {
  let s = 0;
  let c = 0;
  for (const x of values) {
    const t = s + x;
    c += Math.abs(s) >= Math.abs(x) ? s - t + x : x - t + s;
    s = t;
  }
  return s + c;
}

function meanAndSS(values) {
  const n = values.length;
  const m = sum(values) / n;
  const d = values.map((x) => x - m);
  const ss = sum(d.map((v) => v * v)) - sum(d) ** 2 / n;
  return [m, Math.max(ss, 0)];
}

function needTwo(n) {
  if (n < 2) throw new StatisticsError(`sample statistics need at least 2 data points, got ${n}`);
}

export function mean(data) {
  const values = toNumbers(data);
  return sum(values) / values.length;
}

export function sumOfSquares(data) {
  return meanAndSS(toNumbers(data))[1];
}

export function populationVariance(data) {
  const values = toNumbers(data);
  return meanAndSS(values)[1] / values.length;
}

export function sampleVariance(data) {
  const values = toNumbers(data);
  needTwo(values.length);
  return meanAndSS(values)[1] / (values.length - 1);
}

export function populationStdev(data) {
  return Math.sqrt(populationVariance(data));
}

export function sampleStdev(data) {
  return Math.sqrt(sampleVariance(data));
}

export function coefficientOfVariation(data, { population = false } = {}) {
  const values = toNumbers(data);
  const n = values.length;
  if (!population) needTwo(n);
  const [m, ss] = meanAndSS(values);
  if (m === 0) throw new StatisticsError("mean is zero; relative dispersion is undefined");
  return Math.sqrt(ss / (population ? n : n - 1)) / Math.abs(m);
}

export function relativeStdDev(data, options = {}) {
  return 100 * coefficientOfVariation(data, options);
}

export function describe(data, { population = false } = {}) {
  const values = toNumbers(data);
  const n = values.length;
  if (!population) needTwo(n);
  const [m, ss] = meanAndSS(values);
  const variance = ss / (population ? n : n - 1);
  const stdev = Math.sqrt(variance);
  let minimum = values[0];
  let maximum = values[0];
  for (const x of values) {
    if (x < minimum) minimum = x;
    if (x > maximum) maximum = x;
  }
  return {
    n,
    mean: m,
    minimum,
    maximum,
    range: maximum - minimum,
    sumOfSquares: ss,
    variance,
    stdev,
    rsdPercent: m === 0 ? null : 100 * (stdev / Math.abs(m)),
    population,
  };
}
