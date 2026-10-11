# statistics-calculator-toolkit

Small, dependency-free libraries for the mean, sum of squared deviations,
population and sample variance, population and sample standard deviation,
coefficient of variation and relative standard deviation (RSD). Ten
languages share one API, one algorithm and one set of test vectors.

Documentation: <https://ramesh-xyz.github.io/statistics-calculator-toolkit/>

## Problems it solves

- **Picking the wrong formula.** Population and sample versions are separate,
  explicitly named functions.
- **Silent precision loss.** The shortcut `Σx² − (Σx)²/n` can return zero or
  a negative variance for data far from zero. Every implementation here uses
  a corrected two-pass algorithm with compensated summation.
- **Garbage in, number out.** NaN, infinities and (in dynamic languages)
  `null`, booleans and strings raise an error naming the bad item. Missing
  values are never skipped silently.
- **Undefined RSD.** A zero mean raises an error instead of returning
  infinity.

## Packages

| language | directory | registry | install |
|---|---|---|---|
| Python | [`src/sdtoolkit`](src/sdtoolkit) | PyPI | `pip install sdtoolkit` |
| JavaScript / TypeScript | [`js`](js) | npm | `npm install @rameshxyz/sdtoolkit` |
| Rust | [`rust`](rust) | crates.io | `cargo add sdtoolkit` |
| Go | [`go/sdtoolkit`](go/sdtoolkit) | Go modules | `go get github.com/Ramesh-xyz/statistics-calculator-toolkit/go/sdtoolkit` |
| R | [`r`](r) | CRAN | `install.packages("sdcalc")` |
| Java / Kotlin | [`java`](java) | Maven Central | `io.github.ramesh-xyz:sdtoolkit` |
| C# / .NET | [`dotnet`](dotnet) | NuGet | `dotnet add package SdToolkit` |
| Ruby | [`ruby`](ruby) | RubyGems | `gem install sdtoolkit` |
| PHP | [`php`](php) | Packagist | `composer require ramesh-xyz/sdtoolkit` |
| Dart / Flutter | [`dart`](dart) | pub.dev | `dart pub add sdtoolkit` |

Each package is released on its own from a git tag (see
[RELEASING.md](RELEASING.md)); [CHANGELOG.md](CHANGELOG.md) lists what has
shipped. Each directory's README has usage examples for that language. The
Python package and its command-line tool are documented in
[docs/python.md](docs/python.md).

## Example

```python
>>> import sdtoolkit as sd
>>> data = [2, 4, 4, 4, 5, 5, 7, 9]
>>> sd.population_variance(data), sd.population_stdev(data)
(4.0, 2.0)
>>> sd.sample_variance(data), sd.sample_stdev(data)
(4.571428571428571, 2.138089935299395)
>>> sd.relative_std_dev(data)
42.7617987059879
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

The same numbers come out of every language; [docs/api.md](docs/api.md)
lists the function names per language, the shared edge-case behaviour and the
floating-point differences.

## Formulas

```
x̄   = Σxᵢ / n
SS   = Σ (xᵢ − x̄)²
σ²   = SS / N              σ = √σ²
s²   = SS / (n − 1)        s = √s²
CV   = s / |x̄|
RSD  = 100 × s / |x̄|  %
```

Guides: [standard deviation](docs/standard-deviation.md),
[variance](docs/variance.md),
[sample vs population](docs/sample-vs-population.md),
[relative standard deviation](docs/relative-standard-deviation.md),
[outliers](docs/outliers.md). Illustrative datasets and hand-worked examples
are in [examples/](examples).

## Interactive Standard Deviation Calculator

For an interactive online calculator and additional worked examples, visit [StandardDeviationCalculator.net](https://standarddeviationcalculator.net/).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
