# Changelog

## 0.1.0 - 2026-10-11

First release.

- `mean`, `sum_of_squares`, `population_variance`, `sample_variance`,
  `population_stdev`, `sample_stdev`, `relative_std_dev`,
  `coefficient_of_variation` and `describe`.
- Two-pass variance algorithm using `math.fsum`.
- Input validation with `StatisticsError` (subclass of `ValueError`).
- Command-line interface: `python -m sdtoolkit`, with `--population` and
  `--csv FILE --column NAME`.
- Documentation in `docs/`, illustrative datasets and worked examples in
  `examples/`.
