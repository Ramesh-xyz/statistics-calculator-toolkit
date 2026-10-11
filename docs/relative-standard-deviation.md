# Relative standard deviation and coefficient of variation

The standard deviation is in the units of the data, so it cannot be compared
directly across datasets with different scales. An SD of 0.03 mg/L and an SD
of 8.9 exam points say nothing about which is "more variable" until each is
put next to its mean.

```
coefficient of variation   CV  = s / |x̄|          (a ratio)
relative standard deviation RSD = 100 × s / |x̄|   (a percentage)
```

They are the same quantity in two forms. sdtoolkit provides both:

- `coefficient_of_variation(data, population=False)` returns the ratio.
- `relative_std_dev(data, population=False)` returns the percentage.

Both use the sample SD by default; pass `population=True` to use the
population SD. Different fields use "CV" and "RSD" for both forms, so always
check whether a reported value is a ratio or a percentage.

```python
>>> import sdtoolkit as sd
>>> lab = [12.41, 12.38, 12.45, 12.40, 12.36, 12.43, 12.39, 12.44, 12.37, 12.42]
>>> round(sd.relative_std_dev(lab), 3)
0.244
>>> scores = [72, 85, 64, 91, 78, 69, 88, 75, 82, 70]
>>> round(sd.relative_std_dev(scores), 2)
11.53
>>> round(sd.coefficient_of_variation(scores), 4)
0.1153
```

The replicate readings vary by about 0.24 % of their mean; the exam scores by
about 11.5 %. (Both datasets are illustrative, from
`examples/sample-datasets.csv`.)

## Typical uses

- **Precision of repeated measurements.** Analytical labs report the RSD of
  replicate measurements as a measure of repeatability. Acceptable limits
  depend on the method and the concentration and are set by the relevant
  method or standard, not by a universal rule.
- **Comparing variability across scales.** Body mass of mice vs. elephants,
  or prices of two products, where absolute SDs differ by orders of
  magnitude.

You can also try your own numbers with this
[relative standard deviation calculator](https://standarddeviationcalculator.net/relative-standard-deviation-calculator/).

## When it breaks

RSD/CV only make sense for data on a **ratio scale**: a scale with a true
zero, where zero means "none of the quantity" and all values are
non-negative. Mass, length, concentration, count, and kelvin qualify.

**Mean of zero.** The ratio is undefined. sdtoolkit raises
`StatisticsError` instead of returning infinity:

```python
>>> sd.relative_std_dev([-1, 1])
Traceback (most recent call last):
  ...
sdtoolkit.core.StatisticsError: mean is zero; relative dispersion is undefined
```

`describe` reports `rsd_percent=None` in this case instead of raising.

**Mean near zero.** The ratio explodes. A small shift in the mean produces a
huge change in RSD even though the spread has not changed:

```python
>>> round(sd.relative_std_dev([-0.9, 1.1]), 1)
1414.2
>>> round(sd.relative_std_dev([-0.8, 1.2]), 1)
707.1
```

**Negative values or an arbitrary zero.** Temperatures in °C or °F, dates,
and differences have a zero that is a convention, not an absence. The same
temperatures give a different RSD in °C and °F, so the number has no
physical meaning:

```python
>>> celsius = [14.2, 15.8, 13.9, 16.4, 17.1, 15.0, 12.7, 14.8, 16.0, 15.5]
>>> fahrenheit = [c * 9 / 5 + 32 for c in celsius]
>>> round(sd.relative_std_dev(celsius), 2), round(sd.relative_std_dev(fahrenheit), 2)
(8.6, 3.95)
```

sdtoolkit divides by |mean| so the result is never negative, but that does
not make RSD meaningful for data with a negative mean. For such data report
the SD itself.
