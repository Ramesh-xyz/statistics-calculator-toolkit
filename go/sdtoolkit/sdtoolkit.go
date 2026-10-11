// Package sdtoolkit computes the mean, sum of squared deviations, population
// and sample variance, standard deviation, coefficient of variation and
// relative standard deviation of a slice of float64 values.
//
// Variance uses a corrected two-pass algorithm with Neumaier compensated
// summation; the shortcut Σx² − (Σx)²/n is never used. Input is validated:
// empty slices, NaN and ±Inf return errors instead of a misleading number.
// Every error wraps one of the sentinel errors, so use errors.Is to check.
package sdtoolkit

import (
	"errors"
	"fmt"
	"math"
)

// Sentinel errors. Returned errors wrap these.
var (
	ErrEmpty     = errors.New("no data points: at least one value is required")
	ErrTooFew    = errors.New("sample statistics need at least 2 data points")
	ErrNonFinite = errors.New("value is not finite")
	ErrZeroMean  = errors.New("mean is zero; relative dispersion is undefined")
)

// Summary is the result of Describe. RSDPercent is nil when the mean is 0.
type Summary struct {
	N            int
	Mean         float64
	Min          float64
	Max          float64
	Range        float64
	SumOfSquares float64
	Variance     float64
	Stdev        float64
	RSDPercent   *float64
	Population   bool
}

// neumaier returns the compensated sum of f(i) for i in [0, n).
func neumaier(n int, f func(int) float64) float64 {
	var sum, c float64
	for i := 0; i < n; i++ {
		x := f(i)
		t := sum + x
		if math.Abs(sum) >= math.Abs(x) {
			c += (sum - t) + x
		} else {
			c += (x - t) + sum
		}
		sum = t
	}
	return sum + c
}

func validate(data []float64) error {
	if len(data) == 0 {
		return ErrEmpty
	}
	for i, x := range data {
		if math.IsNaN(x) {
			return fmt.Errorf("item %d: NaN is not allowed: %w", i, ErrNonFinite)
		}
		if math.IsInf(x, 0) {
			return fmt.Errorf("item %d: infinity is not allowed: %w", i, ErrNonFinite)
		}
	}
	return nil
}

func needTwo(n int) error {
	if n < 2 {
		return fmt.Errorf("%w, got %d", ErrTooFew, n)
	}
	return nil
}

// meanAndSS assumes validated data.
func meanAndSS(data []float64) (float64, float64) {
	n := len(data)
	m := neumaier(n, func(i int) float64 { return data[i] }) / float64(n)
	sq := neumaier(n, func(i int) float64 { d := data[i] - m; return d * d })
	sd := neumaier(n, func(i int) float64 { return data[i] - m })
	return m, math.Max(sq-sd*sd/float64(n), 0)
}

// Mean returns the arithmetic mean.
func Mean(data []float64) (float64, error) {
	if err := validate(data); err != nil {
		return 0, err
	}
	return neumaier(len(data), func(i int) float64 { return data[i] }) / float64(len(data)), nil
}

// SumOfSquares returns SS = Σ(x − mean)².
func SumOfSquares(data []float64) (float64, error) {
	if err := validate(data); err != nil {
		return 0, err
	}
	_, ss := meanAndSS(data)
	return ss, nil
}

// PopulationVariance returns SS / N. A single value gives 0.
func PopulationVariance(data []float64) (float64, error) {
	ss, err := SumOfSquares(data)
	if err != nil {
		return 0, err
	}
	return ss / float64(len(data)), nil
}

// SampleVariance returns SS / (n − 1) (Bessel's correction). Needs n ≥ 2.
func SampleVariance(data []float64) (float64, error) {
	ss, err := SumOfSquares(data)
	if err != nil {
		return 0, err
	}
	if err := needTwo(len(data)); err != nil {
		return 0, err
	}
	return ss / float64(len(data)-1), nil
}

// PopulationStdev returns √(SS / N).
func PopulationStdev(data []float64) (float64, error) {
	v, err := PopulationVariance(data)
	return math.Sqrt(v), err
}

// SampleStdev returns √(SS / (n − 1)). Needs n ≥ 2.
func SampleStdev(data []float64) (float64, error) {
	v, err := SampleVariance(data)
	return math.Sqrt(v), err
}

// CoefficientOfVariation returns SD / |mean| as a ratio (0.05 means 5 %).
// It uses the sample standard deviation unless population is true, and
// returns ErrZeroMean when the mean is 0.
func CoefficientOfVariation(data []float64, population bool) (float64, error) {
	s, err := Describe(data, population)
	if err != nil {
		return 0, err
	}
	if s.RSDPercent == nil {
		return 0, ErrZeroMean
	}
	return s.Stdev / math.Abs(s.Mean), nil
}

// RelativeStdDev returns 100 × SD / |mean|, in percent. See CoefficientOfVariation.
func RelativeStdDev(data []float64, population bool) (float64, error) {
	cv, err := CoefficientOfVariation(data, population)
	return 100 * cv, err
}

// Describe returns all statistics at once. population=false uses n − 1 and
// needs at least two values; population=true uses N.
func Describe(data []float64, population bool) (Summary, error) {
	if err := validate(data); err != nil {
		return Summary{}, err
	}
	n := len(data)
	div := float64(n)
	if !population {
		if err := needTwo(n); err != nil {
			return Summary{}, err
		}
		div = float64(n - 1)
	}
	m, ss := meanAndSS(data)
	lo, hi := data[0], data[0]
	for _, x := range data[1:] {
		lo, hi = math.Min(lo, x), math.Max(hi, x)
	}
	v := ss / div
	sd := math.Sqrt(v)
	s := Summary{N: n, Mean: m, Min: lo, Max: hi, Range: hi - lo,
		SumOfSquares: ss, Variance: v, Stdev: sd, Population: population}
	if m != 0 {
		rsd := 100 * (sd / math.Abs(m))
		s.RSDPercent = &rsd
	}
	return s, nil
}
