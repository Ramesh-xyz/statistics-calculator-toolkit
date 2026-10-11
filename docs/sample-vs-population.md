# Sample vs population

Both formulas start from the same sum of squared deviations, SS. They differ
only in what SS is divided by:

| | variance | standard deviation | sdtoolkit |
|---|---|---|---|
| population | SS / N | √(SS / N) | `population_variance`, `population_stdev` |
| sample | SS / (n − 1) | √(SS / (n − 1)) | `sample_variance`, `sample_stdev` |

## Which one to use

Use the **population** formulas when the data are every member of the group
you want to describe: all ten machines on one production line, every
employee's salary at a company, the final scores of everyone who sat an exam
and nobody else.

Use the **sample** formulas when the data are a subset and you want to say
something about the larger group they came from: 30 bolts pulled from a
week's output, a survey of 500 voters, five replicate readings of a solution
whose true concentration is unknown.

In practice most data are samples, which is why sdtoolkit's `describe`,
`relative_std_dev`, `coefficient_of_variation` and the CLI default to the
sample formulas.

## Why n − 1 (Bessel's correction)

The deviations in SS are measured from the sample mean x̄, not from the true
population mean μ, which is unknown. x̄ is, by construction, the value that
makes the sum of squared deviations as small as possible. Any other centre,
including μ, gives a larger sum. So SS computed around x̄ is on average a
little too small, and SS / n underestimates the population variance.

The size of that shortfall is known: on average, SS around x̄ equals
(n − 1) × σ². Dividing by n − 1 instead of n removes the bias, so the sample
variance s² is an unbiased estimator of σ². This adjustment is called
Bessel's correction.

Another way to see it: the n deviations xᵢ − x̄ always sum to zero, so once
n − 1 of them are known the last one is fixed. Only n − 1 of them carry
independent information. This count is the *degrees of freedom*.

Two consequences:

- The sample formulas need at least two values. With one value there are zero
  degrees of freedom and no information about spread, so sdtoolkit raises
  `StatisticsError` instead of returning 0 or dividing by zero.
- Taking the square root reintroduces a small bias: s is unbiased for σ²
  but slightly underestimates σ on average. For most purposes this is
  ignored; the effect shrinks as n grows.

## How much it matters

The ratio between the two standard deviations is √(n / (n − 1)):

```python
>>> import sdtoolkit as sd
>>> data = [2, 4, 4, 4, 5, 5, 7, 9]
>>> sd.population_stdev(data), sd.sample_stdev(data)
(2.0, 2.138089935299395)
>>> sd.population_variance([10, 20]), sd.sample_variance([10, 20])
(25.0, 50.0)
```

With 2 values the sample variance is double the population variance. With 8
values the SDs differ by about 7 %; with 100 values by about 0.5 %. The choice
matters most for small datasets, which is also where it is most often made
carelessly.

```python
>>> sd.population_variance([7])
0.0
>>> sd.sample_variance([7])
Traceback (most recent call last):
  ...
sdtoolkit.core.StatisticsError: sample statistics need at least 2 data points, got 1
```
