# sdtoolkit for Java

Mean, sum of squares, population and sample variance, standard deviation,
coefficient of variation and relative standard deviation (RSD) for Java 11+.
No runtime dependencies. Also usable from Kotlin, Scala and other JVM
languages without a wrapper.

## Install

Maven:

```xml
<dependency>
  <groupId>io.github.ramesh-xyz</groupId>
  <artifactId>sdtoolkit</artifactId>
  <version>0.1.0</version>
</dependency>
```

Gradle:

```kotlin
implementation("io.github.ramesh-xyz:sdtoolkit:0.1.0")
```

## Usage

```java
import io.github.rameshxyz.sdtoolkit.SdToolkit;
import io.github.rameshxyz.sdtoolkit.StatisticsException;

double[] data = {2, 4, 4, 4, 5, 5, 7, 9};
SdToolkit.sampleStdev(data);          // 2.138089935299395
SdToolkit.populationStdev(data);      // 2.0
SdToolkit.relativeStdDev(data);       // 42.7617987059879  (percent, sample)
SdToolkit.describe(data, true);
// Summary{n=8, mean=5.0, minimum=2.0, maximum=9.0, range=7.0, sumOfSquares=32.0,
//         variance=4.0, stdev=2.0, rsdPercent=OptionalDouble[40.0], population=true}

try {
    SdToolkit.relativeStdDev(-1, 1);
} catch (StatisticsException e) {
    e.getMessage();                   // "mean is zero; relative dispersion is undefined"
}
```

Kotlin:

```kotlin
val sd = SdToolkit.sampleStdev(2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0)
```

## Functions

All are static methods on `SdToolkit` and take `double...`.

| method | returns |
|---|---|
| `mean(data)` | arithmetic mean |
| `sumOfSquares(data)` | SS = Σ(x − x̄)² |
| `populationVariance(data)` | SS / N |
| `sampleVariance(data)` | SS / (n − 1) |
| `populationStdev(data)` | √(SS / N) |
| `sampleStdev(data)` | √(SS / (n − 1)) |
| `coefficientOfVariation(data[, population])` | SD / \|mean\| as a ratio |
| `relativeStdDev(data[, population])` | 100 × SD / \|mean\| in percent |
| `describe(data[, population])` | `Summary` with all of the above plus min, max, range |

`population` defaults to `false` (sample formulas, divisor n − 1). The
formulas are derived step by step in the
[standard deviation formula reference](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Behaviour

All errors are `StatisticsException`, a subclass of `IllegalArgumentException`.

| input | result |
|---|---|
| empty array or `null` | throws, `no data points` |
| one value, sample statistic | throws, `at least 2` |
| one value, population variance | `0.0` |
| NaN or ±infinity | throws, names the index |
| mean exactly 0, CV / RSD | throws, `mean is zero` |
| mean exactly 0, `describe` | `getRsdPercent()` is `OptionalDouble.empty()` |
| negative mean | CV and RSD use \|mean\| |

## Precision

Values are `double` (IEEE 754 binary64). Variance uses a corrected two-pass
algorithm with Neumaier-compensated sums, so data far from zero such as
`1e9 + {4, 7, 13, 16}` gives the exact sample variance `30.0`. Results agree
with the Python implementation (which uses the exactly rounded `math.fsum`)
to about 1e-12 relative tolerance but are not guaranteed bit-identical.
Convert `BigDecimal` inputs with `doubleValue()` first.

## Links

- Source: https://github.com/Ramesh-xyz/statistics-calculator-toolkit
- Documentation: https://ramesh-xyz.github.io/statistics-calculator-toolkit/
- License: MIT
