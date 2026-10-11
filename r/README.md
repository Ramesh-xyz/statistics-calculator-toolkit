# sdcalc (R)

Population and sample variance and standard deviation, sum of squared
deviations, coefficient of variation and relative standard deviation (RSD)
for R, with strict input validation. No dependencies beyond base R.

This is the R port of
[statistics-calculator-toolkit](https://github.com/Ramesh-xyz/statistics-calculator-toolkit).
Every language in that repository follows the same
[API contract](https://ramesh-xyz.github.io/statistics-calculator-toolkit/api.html)
and is tested against the same known values. The package is called `sdcalc`
because the name `sdtoolkit` belongs to an archived CRAN package.

## Why not just `sd()` and `var()`?

`stats::sd()` and `stats::var()` compute the same sample statistics. sdcalc
adds:

- explicit population formulas (`population_variance`, `population_stdev`);
- CV and RSD that fail on a zero mean instead of returning `Inf` or `NaN`;
- errors instead of a silent `NA` for missing, infinite, logical or
  character input;
- `describe()`, which returns n, mean, min, max, range, SS, variance, SD
  and RSD in one validated call.

## Install

Until the CRAN release, install from GitHub:

```r
# install.packages("remotes")
remotes::install_github("Ramesh-xyz/statistics-calculator-toolkit", subdir = "r")
```

## Usage

```r
library(sdcalc)
x <- c(2, 4, 4, 4, 5, 5, 7, 9)

sum_of_squares(x)                       # 32
population_variance(x)                  # 4
population_stdev(x)                     # 2
sample_variance(x)                      # 4.571429
sample_stdev(x)                         # 2.13809
relative_std_dev(x)                     # 42.7618
coefficient_of_variation(x, population = TRUE)  # 0.4

describe(x, population = TRUE)
#> n               8
#> mean            5
#> min             2
#> max             9
#> range           7
#> sum of squares  32
#> variance        4
#> std dev         2
#> RSD (%)         40
#> (population formulas, divisor: N)

sum_of_squares(c(1, NA, 3))
#> Error: item 2: NA (missing value) is not allowed
```

## Functions

| function | returns |
|---|---|
| `sum_of_squares(x)` | SS = Σ(x − x̄)² |
| `population_variance(x)` | SS / N |
| `sample_variance(x)` | SS / (n − 1) |
| `population_stdev(x)` | √(SS / N) |
| `sample_stdev(x)` | √(SS / (n − 1)) |
| `coefficient_of_variation(x, population = FALSE)` | SD / \|x̄\|, as a ratio |
| `relative_std_dev(x, population = FALSE)` | 100 × SD / \|x̄\|, in percent |
| `describe(x, population = FALSE)` | list of class `sdcalc_summary` with `n`, `mean`, `minimum`, `maximum`, `range`, `sum_of_squares`, `variance`, `stdev`, `rsd_percent`, `population` |

Unlike the other ports there is no exported `mean()`, because it would mask
`base::mean()`; use `base::mean()` or `describe(x)$mean`. The formulas are
worked through step by step on the
[standard deviation formula reference](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Behaviour and edge cases

Errors have class `sdcalc_error`, so they can be caught with
`tryCatch(..., sdcalc_error = function(e) ...)`.

| input | result |
|---|---|
| empty vector or `NULL` | error, `no data points` |
| one value, sample statistic | error, `at least 2` |
| one value, population variance/stdev | `0` |
| `NA`, `NaN`, `Inf`, `-Inf` | error naming the position (1-based) |
| logical, character, complex, list or factor input | error |
| mean exactly zero, CV or RSD | error, `mean is zero` |
| mean exactly zero, `describe()` | `rsd_percent` is `NA_real_` |
| negative mean | CV and RSD use \|mean\| |

## Precision

Integers are converted to double. The mean comes from `base::mean()`, which
accumulates in long double where the platform has it and refines the result
with a second pass; the sum of squares uses the corrected two-pass formula
`sum(d^2) - sum(d)^2 / n`. Data far from zero (for example
`1e9 + c(4, 7, 13, 16)`) still gives the exact sample variance `30`. Results
agree with the other language ports to about 1e-12 relative tolerance.

## License

MIT
