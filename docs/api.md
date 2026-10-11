---
title: API contract
---

# API contract (all languages)

Every implementation in this repository exposes the same nine operations,
uses the same algorithm, and is tested against the same known values. Names
follow each language's conventions.

| operation | Python, Ruby, Rust, R | JavaScript, Dart, Java, PHP | Go, C# |
|---|---|---|---|
| arithmetic mean | `mean` | `mean` | `Mean` |
| Σ(x − x̄)² | `sum_of_squares` | `sumOfSquares` | `SumOfSquares` |
| SS / N | `population_variance` | `populationVariance` | `PopulationVariance` |
| SS / (n − 1) | `sample_variance` | `sampleVariance` | `SampleVariance` |
| √(SS / N) | `population_stdev` | `populationStdev` | `PopulationStdev` |
| √(SS / (n − 1)) | `sample_stdev` | `sampleStdev` | `SampleStdev` |
| SD / \|x̄\| (ratio) | `coefficient_of_variation` | `coefficientOfVariation` | `CoefficientOfVariation` |
| 100 × SD / \|x̄\| (%) | `relative_std_dev` | `relativeStdDev` | `RelativeStdDev` |
| all of the above + min, max, range | `describe` | `describe` | `Describe` |

`coefficient_of_variation`, `relative_std_dev` and `describe` take a
`population` flag (default **false**, i.e. sample formulas). The R package is
named `sdcalc` because `sdtoolkit` is an archived CRAN name. It does not
export `mean`, which would mask `base::mean()`; use `describe(x)$mean` for
the validated mean.

The formulas are explained step by step on the
[standard deviation formula reference](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Algorithm

1. Validate every value (see below) and count `n`.
2. `m = sum(x) / n`, where the sum is compensated: Python uses `math.fsum`
   (exactly rounded), R uses its long-double `sum`/`mean`, every other
   language uses Neumaier summation.
3. `d_i = x_i − m`.
4. `SS = sum(d_i²) − sum(d_i)² / n`, both sums compensated, clamped to ≥ 0.
   The second term is zero in exact arithmetic; it removes rounding error
   left in `m` (corrected two-pass algorithm).
5. Divide by `N` or `n − 1`; `sqrt` for the standard deviation.

The textbook shortcut `Σx² − (Σx)²/n` is never used: on data such as
`1e9 + {4, 7, 13, 16}` it loses every significant digit.

## Behaviour

| input | result |
|---|---|
| empty | error, message contains `no data points` |
| one value, sample statistic | error, message contains `at least 2` |
| one value, population variance / stdev | `0` |
| NaN or ±infinity | error, names the index and `NaN` / `infinity` |
| `null`/`nil`/`None`, booleans, strings (dynamic languages) | error naming the index |
| mean exactly `0`, CV or RSD | error, message contains `mean is zero` |
| mean exactly `0`, `describe` | RSD field is absent: `None`, `null`, `nil`, `NA` or `Option::None` |
| negative mean | CV and RSD use \|mean\|, so they are positive |

Missing values are never skipped silently.

## Shared test vectors

Every test suite checks at least these values.

| data | statistic | expected |
|---|---|---|
| `2, 4, 4, 4, 5, 5, 7, 9` | mean | `5` |
| | sum of squares | `32` |
| | population variance / stdev | `4` / `2` |
| | sample variance | `32/7 = 4.571428571428571` |
| | sample stdev | `2.138089935299395` |
| | RSD sample / population | `42.7617987059879` / `40` |
| `1e9+4, 1e9+7, 1e9+13, 1e9+16` | sum of squares, sample variance | `90`, `30` (exact) |
| `-2, -4, -6` | population RSD | same as for `2, 4, 6` |
| `7` | population variance | `0` |
| `-1, 1` | RSD | error (`mean is zero`) |

## Floating-point notes

All implementations work in IEEE 754 binary64 (`double`). Results agree to
about 1e-12 relative tolerance; they are not guaranteed to be bit-identical
across languages because the compensated sums differ slightly (Python's
`fsum` is exactly rounded, Neumaier is not). Arbitrary-precision inputs
(Python `Decimal`/`Fraction`, Java `BigDecimal`, Ruby `Rational`/`BigDecimal`)
are converted to binary64 first.
