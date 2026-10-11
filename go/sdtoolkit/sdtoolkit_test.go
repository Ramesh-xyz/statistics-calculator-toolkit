package sdtoolkit

import (
	"errors"
	"math"
	"strings"
	"testing"
)

var classic = []float64{2, 4, 4, 4, 5, 5, 7, 9}

func must(t *testing.T) func(float64, error) float64 {
	return func(v float64, err error) float64 {
		t.Helper()
		if err != nil {
			t.Fatal(err)
		}
		return v
	}
}

func close(a, b float64) bool { return math.Abs(a-b) <= 1e-12*math.Max(math.Abs(a), math.Abs(b)) }

func TestClassic(t *testing.T) {
	cases := []struct {
		name string
		f    func([]float64) (float64, error)
		want float64
	}{
		{"mean", Mean, 5},
		{"ss", SumOfSquares, 32},
		{"pvar", PopulationVariance, 4},
		{"pstdev", PopulationStdev, 2},
		{"svar", SampleVariance, 32.0 / 7},
		{"sstdev", SampleStdev, 2.138089935299395},
		{"rsd", func(d []float64) (float64, error) { return RelativeStdDev(d, false) }, 42.7617987059879},
		{"rsd pop", func(d []float64) (float64, error) { return RelativeStdDev(d, true) }, 40},
		{"cv pop", func(d []float64) (float64, error) { return CoefficientOfVariation(d, true) }, 0.4},
	}
	for _, c := range cases {
		if got := must(t)(c.f(classic)); !close(got, c.want) {
			t.Errorf("%s = %v, want %v", c.name, got, c.want)
		}
	}
}

func TestLargeOffsetExact(t *testing.T) {
	data := []float64{1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16}
	if got := must(t)(SumOfSquares(data)); got != 90 {
		t.Errorf("ss = %v, want 90", got)
	}
	if got := must(t)(SampleVariance(data)); got != 30 {
		t.Errorf("svar = %v, want 30", got)
	}
}

func TestNegativeMeanUsesAbs(t *testing.T) {
	a := must(t)(RelativeStdDev([]float64{-2, -4, -6}, true))
	b := must(t)(RelativeStdDev([]float64{2, 4, 6}, true))
	if a != b || a <= 0 {
		t.Errorf("%v != %v", a, b)
	}
}

func TestSingleValue(t *testing.T) {
	if got := must(t)(PopulationVariance([]float64{7})); got != 0 {
		t.Errorf("pvar = %v", got)
	}
	for _, f := range []func([]float64) (float64, error){SampleVariance, SampleStdev} {
		if _, err := f([]float64{7}); !errors.Is(err, ErrTooFew) || !strings.Contains(err.Error(), "at least 2") {
			t.Errorf("err = %v", err)
		}
	}
	if _, err := Describe([]float64{7}, false); !errors.Is(err, ErrTooFew) {
		t.Errorf("err = %v", err)
	}
}

func TestErrors(t *testing.T) {
	cases := []struct {
		data []float64
		want error
		msg  string
	}{
		{nil, ErrEmpty, "no data points"},
		{[]float64{1, math.NaN()}, ErrNonFinite, "item 1: NaN"},
		{[]float64{math.Inf(1)}, ErrNonFinite, "item 0: infinity"},
		{[]float64{1, math.Inf(-1)}, ErrNonFinite, "infinity"},
	}
	for _, c := range cases {
		_, err := Mean(c.data)
		if !errors.Is(err, c.want) || !strings.Contains(err.Error(), c.msg) {
			t.Errorf("Mean(%v) err = %v", c.data, err)
		}
	}
}

func TestZeroMean(t *testing.T) {
	if _, err := RelativeStdDev([]float64{-1, 1}, false); !errors.Is(err, ErrZeroMean) || !strings.Contains(err.Error(), "mean is zero") {
		t.Errorf("err = %v", err)
	}
	s, err := Describe([]float64{-1, 1}, false)
	if err != nil || s.RSDPercent != nil {
		t.Errorf("describe zero mean: %+v %v", s, err)
	}
}

func TestDescribe(t *testing.T) {
	s, err := Describe(classic, true)
	if err != nil {
		t.Fatal(err)
	}
	if s.N != 8 || s.Mean != 5 || s.Min != 2 || s.Max != 9 || s.Range != 7 ||
		s.SumOfSquares != 32 || s.Variance != 4 || s.Stdev != 2 || *s.RSDPercent != 40 || !s.Population {
		t.Errorf("%+v", s)
	}
}
