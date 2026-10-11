# SdToolkit for .NET

Mean, sum of squares, population and sample variance, standard deviation,
coefficient of variation and relative standard deviation (RSD) for .NET 8+.
No dependencies.

## Install

```
dotnet add package SdToolkit
```

## Usage

```csharp
using SdToolkit;

double[] data = { 2, 4, 4, 4, 5, 5, 7, 9 };
Dispersion.SampleStdev(data);       // 2.138089935299395
Dispersion.PopulationStdev(data);   // 2
Dispersion.RelativeStdDev(data);    // 42.7617987059879  (percent, sample)
Dispersion.Describe(data, population: true);
// Summary { N = 8, Mean = 5, Minimum = 2, Maximum = 9, Range = 7, SumOfSquares = 32,
//           Variance = 4, Stdev = 2, RsdPercent = 40, Population = True }

try
{
    Dispersion.RelativeStdDev(new double[] { -1, 1 });
}
catch (StatisticsException e)
{
    Console.WriteLine(e.Message);   // mean is zero; relative dispersion is undefined
}
```

Every method takes `IEnumerable<double>`, so arrays, lists and LINQ queries
all work. Convert `decimal` values with `(double)x` first.

## Functions

| method | returns |
|---|---|
| `Mean(data)` | arithmetic mean |
| `SumOfSquares(data)` | SS = Σ(x − x̄)² |
| `PopulationVariance(data)` | SS / N |
| `SampleVariance(data)` | SS / (n − 1) |
| `PopulationStdev(data)` | √(SS / N) |
| `SampleStdev(data)` | √(SS / (n − 1)) |
| `CoefficientOfVariation(data, population = false)` | SD / \|mean\| as a ratio |
| `RelativeStdDev(data, population = false)` | 100 × SD / \|mean\| in percent |
| `Describe(data, population = false)` | `Summary` record with all of the above plus min, max, range |

The formulas are derived step by step in the
[standard deviation formula reference](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Behaviour

All errors are `StatisticsException`, a subclass of `ArgumentException`.

| input | result |
|---|---|
| empty or `null` | throws, `no data points` |
| one value, sample statistic | throws, `at least 2` |
| one value, population variance | `0` |
| NaN or ±infinity | throws, names the index |
| mean exactly 0, CV / RSD | throws, `mean is zero` |
| mean exactly 0, `Describe` | `RsdPercent` is `null` |
| negative mean | CV and RSD use \|mean\| |

## Precision

Values are `double` (IEEE 754 binary64). Variance uses a corrected two-pass
algorithm with Neumaier-compensated sums, so data far from zero such as
`1e9 + {4, 7, 13, 16}` gives the exact sample variance `30`. Results agree
with the Python implementation (which uses the exactly rounded `math.fsum`)
to about 1e-12 relative tolerance but are not guaranteed bit-identical.

## Links

- Source: https://github.com/Ramesh-xyz/statistics-calculator-toolkit
- Documentation: https://ramesh-xyz.github.io/statistics-calculator-toolkit/
- License: MIT
