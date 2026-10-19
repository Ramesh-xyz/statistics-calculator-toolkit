---
title: Home
---

# statistics-calculator-toolkit

Small, dependency-free libraries for the mean, sum of squared deviations,
population and sample variance, population and sample standard deviation,
coefficient of variation and relative standard deviation (RSD).

Every language exposes the same operations, uses the same numerically
careful algorithm, validates input the same way and is tested against the
same known values. See the [API contract](api.md) for names, behaviour and
floating-point notes.

## Install

| language | registry | install | docs |
|---|---|---|---|
| Python | PyPI | `pip install sdtoolkit` | [Python guide](python.md) |
| JavaScript / TypeScript | npm | `npm install @rameshxyz/sdtoolkit` | [README](https://github.com/Ramesh-xyz/statistics-calculator-toolkit/tree/main/js) |
| Rust | crates.io | `cargo add sdtoolkit` | [README](https://github.com/Ramesh-xyz/statistics-calculator-toolkit/tree/main/rust), [docs.rs](https://docs.rs/sdtoolkit) |
| Go | Go modules | `go get github.com/Ramesh-xyz/statistics-calculator-toolkit/go/sdtoolkit` | [README](https://github.com/Ramesh-xyz/statistics-calculator-toolkit/tree/main/go/sdtoolkit), [pkg.go.dev](https://pkg.go.dev/github.com/Ramesh-xyz/statistics-calculator-toolkit/go/sdtoolkit) |
| R | CRAN | `install.packages("sdcalc")` | [README](https://github.com/Ramesh-xyz/statistics-calculator-toolkit/tree/main/r) |
| Java / Kotlin | Maven Central | `io.github.ramesh-xyz:sdtoolkit` | [README](https://github.com/Ramesh-xyz/statistics-calculator-toolkit/tree/main/java) |
| C# / .NET | NuGet | `dotnet add package SdToolkit` | [README](https://github.com/Ramesh-xyz/statistics-calculator-toolkit/tree/main/dotnet) |
| Ruby | RubyGems | `gem install sdtoolkit` | [README](https://github.com/Ramesh-xyz/statistics-calculator-toolkit/tree/main/ruby) |
| PHP | Packagist | `composer require ramesh-xyz/sdtoolkit` | [README](https://github.com/Ramesh-xyz/statistics-calculator-toolkit/tree/main/php) |
| Dart / Flutter | pub.dev | `dart pub add sdtoolkit` | [README](https://github.com/Ramesh-xyz/statistics-calculator-toolkit/tree/main/dart) |

Each package is released independently from a git tag; the
[changelog](https://github.com/Ramesh-xyz/statistics-calculator-toolkit/blob/main/CHANGELOG.md)
lists what has shipped. Until a language's first release, install it from the
repository directory linked above.

## Example

The classic dataset `2, 4, 4, 4, 5, 5, 7, 9` gives the same results in every
language:

| statistic | value |
|---|---|
| mean | 5 |
| sum of squares | 32 |
| population variance / standard deviation | 4 / 2 |
| sample variance / standard deviation | 4.571428571428571 / 2.138089935299395 |
| RSD, sample / population | 42.76 % / 40 % |

## Guides

- [Standard deviation](standard-deviation.md): what it measures and how to read it
- [Variance](variance.md): the average squared deviation
- [Sample vs population](sample-vs-population.md): when to divide by n − 1
- [Relative standard deviation](relative-standard-deviation.md): comparing spread across scales
- [Outliers](outliers.md): how single extreme values inflate the SD
- [Standard deviation in finance](standard-deviation-in-finance.md): volatility, Sharpe ratio, beta and value at risk

## Source and issues

Code, issues and pull requests:
[github.com/Ramesh-xyz/statistics-calculator-toolkit](https://github.com/Ramesh-xyz/statistics-calculator-toolkit).
For an interactive calculator, see
[standarddeviationcalculator.net](https://standarddeviationcalculator.net/).
