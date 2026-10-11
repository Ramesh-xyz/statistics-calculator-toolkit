# Standard deviation

Standard deviation measures how far values typically sit from their mean. It
is the square root of the variance, so it has the same units as the data: if
the data are in millimetres, so is the standard deviation.

## Definition

For values x₁ … xₙ with mean x̄:

```
SS = Σ (xᵢ − x̄)²                 sum of squared deviations

population SD   σ = √( SS / N )
sample SD       s = √( SS / (n − 1) )
```

Which denominator to use depends on whether the data are the whole group you
care about or a sample drawn from it; see
[sample-vs-population.md](sample-vs-population.md). For a written walk-through
of each symbol, see this
[explanation of the standard deviation formula](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Step by step

Data: 2, 4, 4, 4, 5, 5, 7, 9 (n = 8).

1. Mean: (2 + 4 + 4 + 4 + 5 + 5 + 7 + 9) / 8 = 40 / 8 = 5.
2. Deviations from the mean: −3, −1, −1, −1, 0, 0, 2, 4.
3. Squared deviations: 9, 1, 1, 1, 0, 0, 4, 16. Their sum, SS, is 32.
4. Population variance: 32 / 8 = 4. Population SD: √4 = 2.
5. Sample variance: 32 / 7 = 4.571428… Sample SD: √4.571428… = 2.138089…

The same with sdtoolkit:

```python
>>> import sdtoolkit as sd
>>> data = [2, 4, 4, 4, 5, 5, 7, 9]
>>> sd.mean(data), sd.sum_of_squares(data)
(5.0, 32.0)
>>> sd.population_stdev(data)
2.0
>>> sd.sample_stdev(data)
2.138089935299395
```

## Reading the number

- SD is zero only when every value is identical.
- It is never negative.
- Adding a constant to every value leaves it unchanged; multiplying every
  value by c multiplies it by |c|.
- It is sensitive to extreme values, because deviations are squared. One
  outlier can dominate it; see [outliers.md](outliers.md).
- For data that are roughly bell-shaped (normal), about 68 % of values lie
  within one SD of the mean and about 95 % within two. For skewed or
  multi-modal data those percentages do not hold, and SD alone describes the
  spread poorly.

```python
>>> sd.population_stdev([x + 1000 for x in data])
2.0
>>> sd.population_stdev([x * -3 for x in data])
6.0
```

## How sdtoolkit computes it

The textbook shortcut `Σx² − (Σx)²/n` is algebraically equal to SS but
subtracts two large, nearly equal numbers. With data far from zero the result
can lose all of its significant digits, or even come out negative.

sdtoolkit uses two passes instead: compute the mean, then sum the squared
deviations from it with `math.fsum`, which keeps the summation itself
correctly rounded. A correction term (the sum of the deviations, which is
exactly zero in exact arithmetic) removes the small error left by rounding
the mean.

```python
>>> big = [1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16]
>>> sd.sample_variance(big)
30.0
>>> n = len(big)
>>> naive = (sum(x * x for x in big) - sum(big) ** 2 / n) / (n - 1)
>>> naive == 30.0
False
```

Python's own [`statistics`](https://docs.python.org/3/library/statistics.html)
module computes these with exact rational arithmetic; the test suite checks
sdtoolkit against it.
