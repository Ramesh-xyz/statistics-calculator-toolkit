# sdtoolkit

Standard deviation, variance, sum of squares, coefficient of variation and
relative standard deviation (RSD) for JavaScript and TypeScript. Zero
dependencies, ES module, type definitions included. Node.js 18+ and modern
browsers.

Invalid input throws a `StatisticsError` instead of returning `NaN`.

## Install

```
npm install sdtoolkit
```

## Usage

```js
import * as sd from "sdtoolkit";

const data = [2, 4, 4, 4, 5, 5, 7, 9];
sd.mean(data);                                   // 5
sd.sumOfSquares(data);                           // 32
sd.populationVariance(data);                     // 4
sd.populationStdev(data);                        // 2
sd.sampleVariance(data);                         // 4.571428571428571
sd.sampleStdev(data);                            // 2.138089935299395
sd.relativeStdDev(data);                         // 42.7617987059879
sd.coefficientOfVariation(data, { population: true }); // 0.4

sd.describe(data, { population: true });
// { n: 8, mean: 5, minimum: 2, maximum: 9, range: 7, sumOfSquares: 32,
//   variance: 4, stdev: 2, rsdPercent: 40, population: true }
```

## Functions

| function | returns |
|---|---|
| `mean(data)` | arithmetic mean |
| `sumOfSquares(data)` | SS = Σ(x − x̄)² |
| `populationVariance(data)` | SS / N |
| `sampleVariance(data)` | SS / (n − 1) |
| `populationStdev(data)` | √(SS / N) |
| `sampleStdev(data)` | √(SS / (n − 1)) |
| `coefficientOfVariation(data, { population })` | SD / \|x̄\|, as a ratio |
| `relativeStdDev(data, { population })` | 100 × SD / \|x̄\|, in percent |
| `describe(data, { population })` | all of the above plus minimum, maximum, range |

`data` is any iterable of numbers: an array, a `Set`, a typed array or a
generator. `population` defaults to `false`, so CV, RSD and `describe` use the
sample formulas (divide by n − 1). The formulas are worked through on the
[standard deviation formula reference](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Edge cases

| input | result |
|---|---|
| empty | throws, `no data points` |
| one value, sample statistic | throws, `at least 2` |
| one value, population variance or stdev | `0` |
| `NaN`, `±Infinity` | throws, names the index |
| `null`, `undefined`, booleans, strings, bigints | throws, names the index |
| mean exactly 0, CV or RSD | throws, `mean is zero` |
| mean exactly 0, `describe` | `rsdPercent` is `null` |
| negative mean | CV and RSD use \|mean\| |

Missing values are never skipped. Clean or impute your data first so the
choice is visible in your code.

```js
import { mean, StatisticsError } from "sdtoolkit";
try {
  mean([1, null, 3]);
} catch (e) {
  e instanceof StatisticsError; // true
  e.message; // "item 1: null (missing value); remove or fill it before computing"
}
```

## Precision

Variance uses the corrected two-pass algorithm with Neumaier-compensated sums,
never the shortcut `Σx² − (Σx)²/n`. For `[1e9+4, 1e9+7, 1e9+13, 1e9+16]`,
`sampleVariance` returns exactly `30`; the shortcut formula returns a value
that is badly wrong. Results match the Python implementation to about 1e-12
relative tolerance but are not guaranteed bit-identical, because Python uses
the exactly rounded `math.fsum`.

## Links

- Documentation: https://ramesh-xyz.github.io/statistics-calculator-toolkit/
- Source, other languages and issues: https://github.com/Ramesh-xyz/statistics-calculator-toolkit
- Online calculator: https://standarddeviationcalculator.net/

## License

MIT
