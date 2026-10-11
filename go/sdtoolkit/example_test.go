package sdtoolkit_test

import (
	"errors"
	"fmt"

	"github.com/Ramesh-xyz/statistics-calculator-toolkit/go/sdtoolkit"
)

func Example() {
	data := []float64{2, 4, 4, 4, 5, 5, 7, 9}
	pvar, _ := sdtoolkit.PopulationVariance(data)
	sd, _ := sdtoolkit.SampleStdev(data)
	rsd, _ := sdtoolkit.RelativeStdDev(data, false)
	fmt.Println(pvar, sd, rsd)
	// Output: 4 2.138089935299395 42.7617987059879
}

func ExampleDescribe() {
	s, err := sdtoolkit.Describe([]float64{2, 4, 4, 4, 5, 5, 7, 9}, true)
	if err != nil {
		panic(err)
	}
	fmt.Println(s.N, s.Mean, s.Variance, s.Stdev, *s.RSDPercent)
	// Output: 8 5 4 2 40
}

func ExampleSampleVariance_error() {
	_, err := sdtoolkit.SampleVariance([]float64{5})
	fmt.Println(err, errors.Is(err, sdtoolkit.ErrTooFew))
	// Output: sample statistics need at least 2 data points, got 1 true
}
