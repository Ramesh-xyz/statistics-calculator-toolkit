# sdtoolkit

Standard deviation, variance, sum of squares, coefficient of variation and
relative standard deviation (RSD) for Dart and Flutter. Pure Dart with no
runtime dependencies, so it runs on every platform including the web.

Invalid input throws a `StatisticsException` instead of returning `NaN`.

## Install

```
dart pub add sdtoolkit
```

or, in a Flutter project, `flutter pub add sdtoolkit`.

## Usage

```dart
import 'package:sdtoolkit/sdtoolkit.dart' as sd;

void main() {
  const data = [2, 4, 4, 4, 5, 5, 7, 9];
  print(sd.mean(data));           // 5.0
  print(sd.sampleVariance(data)); // 4.571428571428571
  print(sd.sampleStdev(data));    // 2.138089935299395
  print(sd.relativeStdDev(data)); // 42.7617987059879
  print(sd.describe(data, population: true));
  // Summary(n: 8, mean: 5.0, minimum: 2.0, maximum: 9.0, range: 7.0,
  //   sumOfSquares: 32.0, variance: 4.0, stdev: 2.0, rsdPercent: 40.0,
  //   population: true)
}
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
| `coefficientOfVariation(data, population: false)` | SD / \|x̄\|, as a ratio |
| `relativeStdDev(data, population: false)` | 100 × SD / \|x̄\|, in percent |
| `describe(data, population: false)` | `Summary` with all of the above plus minimum, maximum, range |

`data` is any `Iterable<num>`. `population` defaults to `false`, so CV, RSD
and `describe` use the sample formulas (divide by n − 1). The formulas are
worked through on the
[standard deviation formula reference](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Edge cases

| input | result |
|---|---|
| empty | throws, `no data points` |
| one value, sample statistic | throws, `at least 2` |
| one value, population variance or stdev | `0.0` |
| `double.nan`, `double.infinity` | throws, names the index |
| mean exactly 0, CV or RSD | throws, `mean is zero` |
| mean exactly 0, `describe` | `rsdPercent` is `null` |
| negative mean | CV and RSD use \|mean\| |

Nulls, booleans and strings are rejected by the type system
(`Iterable<num>`), so missing values cannot be skipped silently.

## Precision

Variance uses the corrected two-pass algorithm with Neumaier-compensated sums,
never the shortcut `Σx² − (Σx)²/n`. For `[1e9+4, 1e9+7, 1e9+13, 1e9+16]`,
`sampleVariance` returns exactly `30.0`. Integers are converted to `double`
first; on the web all numbers are already doubles. Results match the other
implementations in this project to about 1e-12 relative tolerance.

## License

MIT
