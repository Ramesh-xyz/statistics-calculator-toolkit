# statistics-calculator-toolkit

`sdtoolkit` is a small, dependency-free Python package for standard
deviation, variance, sum of squares, relative standard deviation (RSD) and
coefficient of variation, with a command-line interface. It uses only the
standard library and supports Python 3.9 and later.

## Problems it solves

- **Picking the wrong formula.** Population and sample versions have
  separate, explicitly named functions, and the CLI prints which divisor it
  used.
- **Silent precision loss.** The shortcut `Σx² − (Σx)²/n` can return zero or
  even a negative variance for data far from zero. sdtoolkit uses a two-pass
  algorithm with `math.fsum`.
- **Garbage in, number out.** `None`, `NaN`, infinities, booleans and strings
  raise a clear error instead of producing a plausible-looking result. Missing
  values are never skipped silently.
- **Undefined RSD.** A zero mean raises an error instead of returning
  infinity or dividing by zero.

## Features

| function | returns |
|---|---|
| `mean(data)` | arithmetic mean |
| `sum_of_squares(data)` | SS = Σ(x − x̄)² |
| `population_variance(data)` | SS / N |
| `sample_variance(data)` | SS / (n − 1) |
| `population_stdev(data)` | √(SS / N) |
| `sample_stdev(data)` | √(SS / (n − 1)) |
| `relative_std_dev(data, population=False)` | 100 × SD / \|mean\|, in percent |
| `coefficient_of_variation(data, population=False)` | SD / \|mean\|, as a ratio |
| `describe(data, population=False)` | `Summary` dataclass with all of the above plus min, max, range |

All errors are raised as `sdtoolkit.StatisticsError`, a subclass of
`ValueError`.

## Install

There is no PyPI release. Install from a clone:

```
git clone https://github.com/Ramesh-xyz/statistics-calculator-toolkit.git
cd statistics-calculator-toolkit
pip install .
```

Or skip installing and point `PYTHONPATH` at `src/`:

```
PYTHONPATH=src python -m sdtoolkit 1 2 3
```

## Usage

### Python

```python
>>> import sdtoolkit as sd
>>> data = [2, 4, 4, 4, 5, 5, 7, 9]
>>> sd.mean(data)
5.0
>>> sd.sum_of_squares(data)
32.0
>>> sd.population_variance(data), sd.population_stdev(data)
(4.0, 2.0)
>>> sd.sample_variance(data), sd.sample_stdev(data)
(4.571428571428571, 2.138089935299395)
>>> sd.relative_std_dev(data)
42.7617987059879
>>> sd.coefficient_of_variation(data, population=True)
0.4
>>> sd.describe(data)
Summary(n=8, mean=5.0, minimum=2.0, maximum=9.0, range=7.0, sum_of_squares=32.0, variance=4.571428571428571, stdev=2.138089935299395, rsd_percent=42.7617987059879, population=False)
>>> sd.describe(data, population=True).as_dict()["stdev"]
2.0
```

### Command line

```console
$ python -m sdtoolkit 2 4 4 4 5 5 7 9
n                8
mean             5
min              2
max              9
range            7
sum of squares   32
sample variance  4.571428571
sample std dev   2.138089935
RSD (%)          42.76179871
(divisor: n - 1)
```

```console
$ python -m sdtoolkit --population 2 4 4 4 5 5 7 9
n                    8
mean                 5
min                  2
max                  9
range                7
sum of squares       32
population variance  4
population std dev   2
RSD (%)              40
(divisor: N)
```

Read one column of a CSV file (lines starting with `#` are treated as
comments):

```console
$ python -m sdtoolkit --csv examples/sample-datasets.csv --column lab_replicate_mg_l
n                10
mean             12.405
min              12.36
max              12.45
range            0.09
sum of squares   0.00825
sample variance  0.0009166666667
sample std dev   0.03027650354
RSD (%)          0.244066937
(divisor: n - 1)
```

Errors go to stderr with exit status 1:

```console
$ python -m sdtoolkit 1 2 x
error: argument 3: 'x' is not a number
$ python -m sdtoolkit 5
error: sample statistics need at least 2 data points, got 1
```

After `pip install .` the same CLI is also available as `sdtoolkit`.

## Population vs sample

Use the population functions when your data are the entire group you are
describing. Use the sample functions when your data are drawn from a larger
group you want to draw conclusions about. The sample formulas divide by
n − 1 (Bessel's correction), which makes the sample variance an unbiased
estimate of the population variance, and they need at least two values.

`describe`, `relative_std_dev`, `coefficient_of_variation` and the CLI
default to the sample formulas. Details:
[docs/sample-vs-population.md](docs/sample-vs-population.md).

## Formulas

```
x̄   = Σxᵢ / n
SS   = Σ (xᵢ − x̄)²
σ²   = SS / N              σ = √σ²
s²   = SS / (n − 1)        s = √s²
CV   = s / |x̄|
RSD  = 100 × s / |x̄|  %
```

Further reading in this repository:

- [docs/standard-deviation.md](docs/standard-deviation.md)
- [docs/variance.md](docs/variance.md)
- [docs/sample-vs-population.md](docs/sample-vs-population.md)
- [docs/relative-standard-deviation.md](docs/relative-standard-deviation.md)
- [docs/outliers.md](docs/outliers.md)

## Example datasets

[`examples/sample-datasets.csv`](examples/sample-datasets.csv) has three
small columns: lab replicate readings, exam scores and daily temperatures.
They are **illustrative values made up for teaching, not real research
data.** [`examples/worked-examples.md`](examples/worked-examples.md) works
through each one by hand and checks the result with the code.

## Accuracy and edge cases

- **Algorithm.** Two passes: the mean, then the squared deviations from it,
  each summed with `math.fsum`. A correction term removes the rounding error
  left in the mean. The test suite compares results with Python's
  `statistics.pvariance`, `variance`, `pstdev` and `stdev` (which use exact
  rational arithmetic) to a relative tolerance of 1e-12, including data
  offset by 10⁹ and 10¹².
- **Accepted input.** Any iterable of `int`, `float`, `decimal.Decimal` or
  `fractions.Fraction`. Decimals and fractions are converted to `float`, so
  their extra precision is not kept and results are always `float`.
- **Rejected input.** `bool`, `None`, strings, NaN, ±infinity, complex
  numbers, and integers too large for a float raise `StatisticsError` naming
  the offending item.
- **Missing values are not skipped.** `None` raises, and an empty CSV cell
  raises with its row number. Remove or impute missing data yourself so the
  choice is visible in your code.
- **Empty input** raises. **Sample statistics with one value** raise.
  Population variance of one value is 0.
- **Zero mean.** `relative_std_dev` and `coefficient_of_variation` raise;
  `describe` sets `rsd_percent` to `None`. RSD is only meaningful for
  ratio-scale data; see
  [docs/relative-standard-deviation.md](docs/relative-standard-deviation.md).

```python
>>> sd.mean([1, None, 3])
Traceback (most recent call last):
  ...
sdtoolkit.core.StatisticsError: item 1: None (missing value); remove or fill it before computing
>>> sd.sample_stdev([1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16]) ** 2
30.0
```

## Tests

```
PYTHONPATH=src python -m unittest discover -s tests
```

The suite uses only `unittest`. GitHub Actions runs it on Python 3.9 to 3.13
(`.github/workflows/tests.yml`).

## Interactive Standard Deviation Calculator

For an interactive online calculator and additional worked examples, visit [StandardDeviationCalculator.net](https://standarddeviationcalculator.net/).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
