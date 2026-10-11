# Outliers and the standard deviation

Standard deviation squares each deviation before averaging. A value twice as
far from the mean contributes four times as much; a value ten times as far
contributes a hundred times as much. One extreme value can therefore dominate
the result.

## A single outlier

Five readings, then the same readings with the last one mistyped as 60
instead of 16:

```python
>>> import sdtoolkit as sd
>>> clean = [12, 13, 14, 15, 16]
>>> typo = [12, 13, 14, 15, 60]
>>> sd.mean(clean), sd.mean(typo)
(14.0, 22.8)
>>> round(sd.sample_stdev(clean), 3), round(sd.sample_stdev(typo), 3)
(1.581, 20.825)
```

One wrong value out of five moved the mean by 63 % and multiplied the SD by
about 13. Where the sum of squares comes from:

| value | deviation from 22.8 | squared |
|---|---|---|
| 12 | −10.8 | 116.64 |
| 13 | −9.8 | 96.04 |
| 14 | −8.8 | 77.44 |
| 15 | −7.8 | 60.84 |
| 60 | 37.2 | 1383.84 |
| | | SS = 1734.8 |

The outlier supplies about 80 % of the sum of squares. The other four values
now also look far from the mean, because the mean itself was pulled toward
the outlier.

```python
>>> sd.sum_of_squares(typo)
1734.8000000000002
>>> round(1383.84 / sd.sum_of_squares(typo), 3)
0.798
```

(The trailing `...0002` is ordinary binary floating-point representation of
1734.8, not an error in the algorithm.)

## Practical consequences

- **Look before you summarise.** Sort the data, check the min and max
  (`describe` reports both), or plot it. A dot plot or histogram makes a
  single wild value obvious. To see how a dataset spreads around its mean,
  a [standard deviation graph](https://standarddeviationcalculator.net/standard-deviation-graph/)
  gives a quick visual check.
- **Find the cause before removing anything.** A typo, a unit mix-up, or an
  instrument fault justifies correcting or dropping a value. A genuine but
  unusual observation does not; removing it understates the real
  variability.
- **Report what you did.** If a value was excluded, say which and why, and
  ideally give the SD with and without it.
- **Consider robust measures** when outliers are expected. The median and
  the interquartile range barely move when one value goes wild; Python's
  `statistics.median` and `statistics.quantiles` compute them. sdtoolkit
  deliberately covers only the mean-based measures.

```python
>>> import statistics
>>> statistics.median(clean), statistics.median(typo)
(14, 14)
```

## Formal outlier tests

Rules such as "more than 3 SD from the mean" are circular when the outlier
itself inflates the SD: in the example above the value 60 is only
37.2 / 20.825 ≈ 1.8 sample SDs from the mean. Methods designed for this
problem (Grubbs' test, the generalised ESD test, the 1.5 × IQR rule) are
described in section 1.3.5.17 of the
[NIST/SEMATECH e-Handbook of Statistical Methods](https://www.itl.nist.gov/div898/handbook/).
