# Variance

Variance is the average squared deviation from the mean:

```
population variance  σ² = Σ (xᵢ − μ)² / N
sample variance      s² = Σ (xᵢ − x̄)² / (n − 1)
```

The numerator, Σ (xᵢ − x̄)², is the *sum of squares* (SS). sdtoolkit exposes it
directly as `sum_of_squares` because it is the building block for variance,
standard deviation, and analysis-of-variance tables.

## Units

Because deviations are squared, variance is in squared units. Exam scores in
points give a variance in points²; lengths in cm give cm². That makes
variance awkward to read directly, which is why the standard deviation (its
square root) is usually reported instead.

Variance is still the more convenient quantity for calculation. For
*independent* random variables, variances add:

```
Var(X + Y) = Var(X) + Var(Y)
Var(X − Y) = Var(X) + Var(Y)
```

Standard deviations do not add this way. Combining measurement
uncertainties, pooling groups, or splitting total variation into parts
(ANOVA) is all done on the variance scale, with a square root taken at the
end if needed.

## Scaling

- Adding a constant c to every value: variance unchanged.
- Multiplying every value by c: variance multiplied by c².

```python
>>> import sdtoolkit as sd
>>> scores = [72, 85, 64, 91, 78, 69, 88, 75, 82, 70]
>>> sd.sum_of_squares(scores)
716.4
>>> sd.sample_variance(scores)
79.6
>>> round(sd.sample_variance([s + 5 for s in scores]), 10)
79.6
>>> round(sd.sample_variance([s / 10 for s in scores]), 10)
0.796
```

## Worked example

Exam scores: 72, 85, 64, 91, 78, 69, 88, 75, 82, 70 (illustrative data from
`examples/sample-datasets.csv`).

1. Mean: 774 / 10 = 77.4.
2. Deviations: −5.4, 7.6, −13.4, 13.6, 0.6, −8.4, 10.6, −2.4, 4.6, −7.4.
3. Squares: 29.16, 57.76, 179.56, 184.96, 0.36, 70.56, 112.36, 5.76,
   21.16, 54.76. SS = 716.4.
4. Sample variance: 716.4 / 9 = 79.6 points².
5. Sample SD: √79.6 ≈ 8.92 points.

To check a dataset of your own in the browser, an
[online variance calculator](https://standarddeviationcalculator.net/variance-calculator/)
shows the same steps.

## Population or sample?

The rule is the same as for standard deviation; see
[sample-vs-population.md](sample-vs-population.md).
