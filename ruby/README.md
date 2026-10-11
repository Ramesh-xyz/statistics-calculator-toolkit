# sdtoolkit (Ruby)

Population and sample standard deviation, variance, sum of squared
deviations, relative standard deviation (RSD) and coefficient of variation
for Ruby. No runtime dependencies. Requires Ruby 3.0 or later.

This is the Ruby port of
[statistics-calculator-toolkit](https://github.com/Ramesh-xyz/statistics-calculator-toolkit).
Every language in that repository follows the same
[API contract](https://ramesh-xyz.github.io/statistics-calculator-toolkit/api.html)
and is tested against the same known values.

## Install

```
gem install sdtoolkit
```

or in a Gemfile:

```ruby
gem "sdtoolkit", "~> 0.1"
```

## Usage

```ruby
require "sdtoolkit"

data = [2, 4, 4, 4, 5, 5, 7, 9]

SDToolkit.mean(data)                                  # => 5.0
SDToolkit.sum_of_squares(data)                        # => 32.0
SDToolkit.population_variance(data)                   # => 4.0
SDToolkit.population_stdev(data)                      # => 2.0
SDToolkit.sample_variance(data)                       # => 4.571428571428571
SDToolkit.sample_stdev(data)                          # => 2.138089935299395
SDToolkit.relative_std_dev(data)                      # => 42.7617987059879
SDToolkit.coefficient_of_variation(data, population: true) # => 0.4

SDToolkit.describe(data, population: true).to_h
# => {n: 8, mean: 5.0, minimum: 2.0, maximum: 9.0, range: 7.0, sum_of_squares: 32.0,
#     variance: 4.0, stdev: 2.0, rsd_percent: 40.0, population: true}

SDToolkit.mean([1, nil])
# SDToolkit::StatisticsError: item 1: nil (missing value); remove or fill it before computing
```

## Functions

| method | returns |
|---|---|
| `mean(data)` | arithmetic mean |
| `sum_of_squares(data)` | SS = Σ(x − x̄)² |
| `population_variance(data)` | SS / N |
| `sample_variance(data)` | SS / (n − 1) |
| `population_stdev(data)` | √(SS / N) |
| `sample_stdev(data)` | √(SS / (n − 1)) |
| `coefficient_of_variation(data, population: false)` | SD / \|x̄\|, as a ratio |
| `relative_std_dev(data, population: false)` | 100 × SD / \|x̄\|, in percent |
| `describe(data, population: false)` | frozen `SDToolkit::Summary` struct with all of the above plus min, max, range |

`data` is any Enumerable. The formulas are worked through step by step on the
[standard deviation formula reference](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Behaviour and edge cases

All errors are `SDToolkit::StatisticsError`, a subclass of `ArgumentError`.

| input | result |
|---|---|
| empty | raises, `no data points` |
| one value, sample statistic | raises, `at least 2` |
| one value, population variance/stdev | `0.0` |
| `nil`, `true`/`false`, strings, `Complex` | raises, naming the index |
| NaN, ±Infinity, integers too large for a Float | raises, naming the index |
| mean exactly zero, CV or RSD | raises, `mean is zero` |
| mean exactly zero, `describe` | `rsd_percent` is `nil` |
| negative mean | CV and RSD use \|mean\| |

Missing values are never skipped silently: remove or impute them yourself.

## Precision

`Integer`, `Float`, `Rational` and `BigDecimal` are accepted and converted to
`Float` (IEEE 754 double), so the extra precision of `Rational` and
`BigDecimal` is not kept. Sums use Neumaier compensated summation and the
variance uses a corrected two-pass algorithm, so data far from zero (for
example `1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16`) still gives the exact sample
variance `30.0`. Results agree with the other language ports to about 1e-12
relative tolerance.

## Tests

```
ruby -Ilib test/test_sdtoolkit.rb
```

## License

MIT
