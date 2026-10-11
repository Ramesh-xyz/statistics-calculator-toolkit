# sdtoolkit for Go

Mean, sum of squared deviations, population and sample variance, standard
deviation, coefficient of variation and relative standard deviation (RSD) for
`[]float64`. No dependencies outside the standard library. Go 1.21+.

API reference: <https://pkg.go.dev/github.com/Ramesh-xyz/statistics-calculator-toolkit/go/sdtoolkit>

## Install

```
go get github.com/Ramesh-xyz/statistics-calculator-toolkit/go/sdtoolkit
```

## Usage

```go
package main

import (
	"errors"
	"fmt"

	"github.com/Ramesh-xyz/statistics-calculator-toolkit/go/sdtoolkit"
)

func main() {
	data := []float64{2, 4, 4, 4, 5, 5, 7, 9}

	sd, _ := sdtoolkit.SampleStdev(data)
	rsd, _ := sdtoolkit.RelativeStdDev(data, false)
	fmt.Println(sd, rsd) // 2.138089935299395 42.7617987059879

	s, _ := sdtoolkit.Describe(data, true)
	fmt.Println(s.Mean, s.Variance, s.Stdev, *s.RSDPercent) // 5 4 2 40

	_, err := sdtoolkit.SampleVariance([]float64{5})
	fmt.Println(errors.Is(err, sdtoolkit.ErrTooFew)) // true
}
```

## Functions

| function | returns |
|---|---|
| `Mean(data)` | arithmetic mean |
| `SumOfSquares(data)` | SS = Σ(x − x̄)² |
| `PopulationVariance(data)` | SS / N |
| `SampleVariance(data)` | SS / (n − 1) |
| `PopulationStdev(data)` | √(SS / N) |
| `SampleStdev(data)` | √(SS / (n − 1)) |
| `CoefficientOfVariation(data, population)` | SD / \|x̄\|, as a ratio |
| `RelativeStdDev(data, population)` | 100 × SD / \|x̄\|, in percent |
| `Describe(data, population)` | `Summary` with all of the above plus min, max, range |

`population == false` uses the sample formulas (divide by n − 1). The
formulas are derived on the
[standard deviation formula reference](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Errors and edge cases

Every error wraps a sentinel, so check with `errors.Is`:

| input | error |
|---|---|
| empty or nil slice | `ErrEmpty` |
| one value, sample statistic | `ErrTooFew` (population variance of one value is `0`) |
| NaN or ±Inf | `ErrNonFinite`, message names the index |
| mean exactly 0, CV or RSD | `ErrZeroMean`; `Describe` sets `RSDPercent` to `nil` |

A negative mean is fine: CV and RSD divide by |mean|.

## Precision

Variance uses a corrected two-pass algorithm with Neumaier compensated
summation, never the shortcut Σx² − (Σx)²/n. For data such as
`1e9 + {4, 7, 13, 16}` the sample variance is exactly `30`. Results match the
Python `sdtoolkit` package to about 1e-12 relative tolerance; they are not
guaranteed to be bit-identical, because Python's `math.fsum` is exactly
rounded and Neumaier summation is not.

## License

MIT. Source: <https://github.com/Ramesh-xyz/statistics-calculator-toolkit>
