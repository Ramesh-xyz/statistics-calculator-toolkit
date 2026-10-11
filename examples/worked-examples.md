# Worked examples

Hand calculations, each followed by the same result from sdtoolkit. Every
code block on this page is checked by running it.

The datasets in [`sample-datasets.csv`](sample-datasets.csv) are
**illustrative numbers invented for teaching. They are not real research or
measurement data.**

## 1. The classic check: 2, 4, 4, 4, 5, 5, 7, 9

| xᵢ | xᵢ − x̄ | (xᵢ − x̄)² |
|---|---|---|
| 2 | −3 | 9 |
| 4 | −1 | 1 |
| 4 | −1 | 1 |
| 4 | −1 | 1 |
| 5 | 0 | 0 |
| 5 | 0 | 0 |
| 7 | 2 | 4 |
| 9 | 4 | 16 |
| Σ = 40 | Σ = 0 | SS = 32 |

- Mean x̄ = 40 / 8 = 5
- Population variance = 32 / 8 = 4; population SD = √4 = 2
- Sample variance = 32 / 7 = 4.571428…; sample SD = √4.571428… = 2.138089…

```python
>>> import sdtoolkit as sd
>>> data = [2, 4, 4, 4, 5, 5, 7, 9]
>>> sd.mean(data), sd.sum_of_squares(data)
(5.0, 32.0)
>>> sd.population_variance(data), sd.population_stdev(data)
(4.0, 2.0)
>>> sd.sample_variance(data)
4.571428571428571
>>> sd.sample_stdev(data)
2.138089935299395
```

## 2. Lab replicates: precision as RSD

Column `lab_replicate_mg_l`: ten readings of one sample, in mg/L.

12.41, 12.38, 12.45, 12.40, 12.36, 12.43, 12.39, 12.44, 12.37, 12.42

1. Sum = 124.05, so x̄ = 12.405 mg/L.
2. Deviations: 0.005, −0.025, 0.045, −0.005, −0.045, 0.025, −0.015, 0.035,
   −0.035, 0.015.
3. Squared deviations, in units of 10⁻⁶ (mg/L)²: 25, 625, 2025, 25, 2025,
   625, 225, 1225, 1225, 225. Sum = 8250, so SS = 0.00825 (mg/L)².
4. Sample variance = 0.00825 / 9 = 0.000916667 (mg/L)².
5. Sample SD = √0.000916667 = 0.0302765 mg/L.
6. RSD = 100 × 0.0302765 / 12.405 = 0.244 %.

```python
>>> lab = [12.41, 12.38, 12.45, 12.40, 12.36, 12.43, 12.39, 12.44, 12.37, 12.42]
>>> sd.mean(lab)
12.405
>>> round(sd.sum_of_squares(lab), 8)
0.00825
>>> round(sd.sample_stdev(lab), 7)
0.0302765
>>> round(sd.relative_std_dev(lab), 3)
0.244
```

## 3. Exam scores: describe()

Column `exam_score`: 72, 85, 64, 91, 78, 69, 88, 75, 82, 70.

1. Sum = 774, x̄ = 77.4.
2. Squared deviations: 29.16, 57.76, 179.56, 184.96, 0.36, 70.56, 112.36,
   5.76, 21.16, 54.76. SS = 716.4.
3. Sample variance = 716.4 / 9 = 79.6; sample SD = √79.6 = 8.9219.
4. Population variance = 716.4 / 10 = 71.64; population SD = 8.4640.

```python
>>> scores = [72, 85, 64, 91, 78, 69, 88, 75, 82, 70]
>>> s = sd.describe(scores)
>>> s.n, s.mean, s.sum_of_squares, s.variance
(10, 77.4, 716.4, 79.6)
>>> round(s.stdev, 4), round(s.rsd_percent, 2)
(8.9219, 11.53)
>>> p = sd.describe(scores, population=True)
>>> round(p.variance, 2), round(p.stdev, 4)
(71.64, 8.464)
```

From the command line:

```console
$ python -m sdtoolkit --csv examples/sample-datasets.csv --column exam_score
n                10
mean             77.4
min              64
max              91
range            27
sum of squares   716.4
sample variance  79.6
sample std dev   8.921883209
RSD (%)          11.52698089
(divisor: n - 1)
```

## 4. Daily temperatures: SD yes, RSD no

Column `daily_temp_c`: 14.2, 15.8, 13.9, 16.4, 17.1, 15.0, 12.7, 14.8,
16.0, 15.5 °C.

x̄ = 151.4 / 10 = 15.14 °C, SS = 15.244, sample SD = √(15.244 / 9) =
1.3015 °C. The SD is meaningful. An RSD is not, because 0 °C is an arbitrary
zero: the same days in °F give a different RSD (see
[docs/relative-standard-deviation.md](../docs/relative-standard-deviation.md)).

```python
>>> temps = [14.2, 15.8, 13.9, 16.4, 17.1, 15.0, 12.7, 14.8, 16.0, 15.5]
>>> round(sd.mean(temps), 2), round(sd.sum_of_squares(temps), 3)
(15.14, 15.244)
>>> round(sd.sample_stdev(temps), 4)
1.3015
```

## 5. Large offsets: why the algorithm matters

Data: 1 000 000 004, 1 000 000 007, 1 000 000 013, 1 000 000 016.

Subtracting the offset 1 000 000 000 does not change the spread, so this is
the same as 4, 7, 13, 16: mean 10, deviations −6, −3, 3, 6, SS = 36 + 9 + 9 +
36 = 90, sample variance 90 / 3 = 30.

```python
>>> big = [1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16]
>>> sd.sum_of_squares(big), sd.sample_variance(big)
(90.0, 30.0)
>>> n = len(big)
>>> (sum(x * x for x in big) - sum(big) ** 2 / n) / (n - 1)  # naive shortcut
0.0
```

The shortcut formula reports zero spread, as if all four values were equal:
Σx² is about 4 × 10¹⁸, and at that size a float cannot represent the
difference of 90 the formula relies on. The two-pass method gets the exact
answer.
