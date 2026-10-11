# Changelog

## Unreleased

- New implementations with the same API, algorithm and test vectors:
  JavaScript/TypeScript (`js/`), Rust (`rust/`), Go (`go/sdtoolkit/`),
  R (`r/`, package `sdcalc`), Java (`java/`), C#/.NET (`dotnet/`),
  Ruby (`ruby/`), PHP (`php/`) and Dart (`dart/`).
- Tag-triggered publish workflows for every registry; see `RELEASING.md`.
- GitHub Pages documentation site built from `docs/`, including the
  cross-language API contract in `docs/api.md`.
- Python: PyPI project URLs, SPDX license metadata.
- JavaScript 0.1.1: same code as 0.1.0, released through the publish
  workflow that creates its own tag.

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
