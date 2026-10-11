# ramesh-xyz/sdtoolkit (PHP)

Population and sample standard deviation, variance, sum of squared
deviations, relative standard deviation (RSD) and coefficient of variation
for PHP 8.1+. No runtime dependencies and no extensions required (the PECL
`stats` extension is not needed).

This is the PHP port of
[statistics-calculator-toolkit](https://github.com/Ramesh-xyz/statistics-calculator-toolkit).
Every language in that repository follows the same
[API contract](https://ramesh-xyz.github.io/statistics-calculator-toolkit/api.html)
and is tested against the same known values.

## Install

```
composer require ramesh-xyz/sdtoolkit
```

## Usage

```php
use RameshXyz\SdToolkit\Dispersion;
use RameshXyz\SdToolkit\StatisticsException;

$data = [2, 4, 4, 4, 5, 5, 7, 9];

Dispersion::mean($data);                          // 5.0
Dispersion::sumOfSquares($data);                  // 32.0
Dispersion::populationVariance($data);            // 4.0
Dispersion::populationStdev($data);               // 2.0
Dispersion::sampleVariance($data);                // 4.571428571428571
Dispersion::sampleStdev($data);                   // 2.138089935299395
Dispersion::relativeStdDev($data);                // 42.7617987059879
Dispersion::coefficientOfVariation($data, true);  // 0.4

$s = Dispersion::describe($data, population: true);
$s->stdev;       // 2.0
$s->rsdPercent;  // 40.0

try {
    Dispersion::mean([1, null]);
} catch (StatisticsException $e) {
    echo $e->getMessage();
    // item 1: null (missing value); remove or fill it before computing
}
```

## Functions

All methods are static on `RameshXyz\SdToolkit\Dispersion` and take any
`iterable` (arrays or generators).

| method | returns |
|---|---|
| `mean($data)` | arithmetic mean |
| `sumOfSquares($data)` | SS = Σ(x − x̄)² |
| `populationVariance($data)` | SS / N |
| `sampleVariance($data)` | SS / (n − 1) |
| `populationStdev($data)` | √(SS / N) |
| `sampleStdev($data)` | √(SS / (n − 1)) |
| `coefficientOfVariation($data, bool $population = false)` | SD / \|x̄\|, as a ratio |
| `relativeStdDev($data, bool $population = false)` | 100 × SD / \|x̄\|, in percent |
| `describe($data, bool $population = false)` | `Summary` with `n`, `mean`, `minimum`, `maximum`, `range`, `sumOfSquares`, `variance`, `stdev`, `rsdPercent`, `population` |

The formulas are worked through step by step on the
[standard deviation formula reference](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Behaviour and edge cases

All errors are `RameshXyz\SdToolkit\StatisticsException`, a subclass of
`InvalidArgumentException`.

| input | result |
|---|---|
| empty | throws, `no data points` |
| one value, sample statistic | throws, `at least 2` |
| one value, population variance/stdev | `0.0` |
| `null`, booleans, strings (even numeric ones like `"2"`), arrays, objects | throws, naming the index |
| `NAN`, `INF`, `-INF` | throws, naming the index |
| mean exactly zero, CV or RSD | throws, `mean is zero` |
| mean exactly zero, `describe` | `rsdPercent` is `null` |
| negative mean | CV and RSD use \|mean\| |

Numeric strings are rejected on purpose: values read from CSV or forms
should be cast explicitly, so a stray empty cell cannot silently become `0`.

## Precision

`int` and `float` are accepted; integers are converted to `float` (IEEE 754
double). Sums use Neumaier compensated summation and the variance uses a
corrected two-pass algorithm, so data far from zero (for example
`1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16`) still gives the exact sample
variance `30.0`. Results agree with the other language ports to about 1e-12
relative tolerance.

## Tests

From the repository root:

```
composer install
composer test
```

## License

MIT
