/** Thrown for empty, too-short or invalid input, and for RSD/CV with a zero mean. */
export class StatisticsError extends Error {}

export interface Options {
  /** Use the population formulas (divide by N). Default false: sample formulas (n - 1). */
  population?: boolean;
}

export interface Summary {
  n: number;
  mean: number;
  minimum: number;
  maximum: number;
  range: number;
  sumOfSquares: number;
  variance: number;
  stdev: number;
  /** null when the mean is zero. */
  rsdPercent: number | null;
  population: boolean;
}

/** Arithmetic mean. */
export function mean(data: Iterable<number>): number;
/** Sum of squared deviations from the mean, SS = Σ(x − x̄)². */
export function sumOfSquares(data: Iterable<number>): number;
/** Population variance, SS / N. */
export function populationVariance(data: Iterable<number>): number;
/** Sample variance, SS / (n − 1). Needs at least 2 values. */
export function sampleVariance(data: Iterable<number>): number;
/** Population standard deviation, √(SS / N). */
export function populationStdev(data: Iterable<number>): number;
/** Sample standard deviation, √(SS / (n − 1)). Needs at least 2 values. */
export function sampleStdev(data: Iterable<number>): number;
/** SD / |mean| as a ratio. Throws when the mean is zero. */
export function coefficientOfVariation(data: Iterable<number>, options?: Options): number;
/** 100 × SD / |mean|, in percent. Throws when the mean is zero. */
export function relativeStdDev(data: Iterable<number>, options?: Options): number;
/** All statistics at once, plus minimum, maximum and range. */
export function describe(data: Iterable<number>, options?: Options): Summary;
