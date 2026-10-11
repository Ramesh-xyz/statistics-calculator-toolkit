"""Core dispersion statistics.

Every function takes an iterable of numbers. Inputs are validated and
converted to ``float`` first:

* ``int``, ``float`` and other real numbers are accepted.
* ``decimal.Decimal`` and ``fractions.Fraction`` are accepted and converted
  to ``float``. Results are floats; exact decimal/rational precision is not
  preserved.
* ``bool``, ``None``, strings, NaN and infinities are rejected with a
  :class:`StatisticsError`. Missing values are never skipped silently: clean
  your data before calling these functions.

Variance is computed with a two-pass algorithm: the mean first, then the
squared deviations from it, summed with :func:`math.fsum`. A small correction
term (the sum of deviations, which is zero in exact arithmetic) absorbs the
rounding error left in the mean. The shortcut ``sum(x**2) - n*mean**2`` is
never used because it loses most of its significant digits when the data
sits far from zero.
"""

import math
import numbers
from dataclasses import dataclass, asdict
from decimal import Decimal
from typing import Iterable, List, Optional

__all__ = [
    "StatisticsError",
    "Summary",
    "mean",
    "sum_of_squares",
    "population_variance",
    "sample_variance",
    "population_stdev",
    "sample_stdev",
    "relative_std_dev",
    "coefficient_of_variation",
    "describe",
]


class StatisticsError(ValueError):
    """Raised for empty, too-short or invalid input."""


def _to_floats(data: Iterable) -> List[float]:
    if isinstance(data, (str, bytes)):
        raise StatisticsError("expected an iterable of numbers, got a string")
    values = []
    for i, x in enumerate(data):
        if isinstance(x, bool):
            raise StatisticsError(f"item {i}: booleans are not numbers ({x!r})")
        if x is None:
            raise StatisticsError(
                f"item {i}: None (missing value); remove or fill it before computing"
            )
        if isinstance(x, str):
            raise StatisticsError(
                f"item {i}: strings are not accepted ({x!r}); convert with float() first"
            )
        if not isinstance(x, (numbers.Real, Decimal)):
            raise StatisticsError(f"item {i}: {x!r} is not a real number")
        try:
            f = float(x)
        except OverflowError:
            raise StatisticsError(f"item {i}: {x!r} is too large for a float") from None
        if math.isnan(f):
            raise StatisticsError(f"item {i}: NaN is not allowed")
        if math.isinf(f):
            raise StatisticsError(f"item {i}: infinity is not allowed")
        values.append(f)
    if not values:
        raise StatisticsError("no data points: at least one value is required")
    return values


def _mean_and_ss(values: List[float]):
    n = len(values)
    m = math.fsum(values) / n
    deviations = [x - m for x in values]
    # Corrected two-pass: sum(d) is 0 in exact arithmetic; subtracting
    # sum(d)**2 / n removes the error caused by rounding in m.
    ss = math.fsum(d * d for d in deviations) - math.fsum(deviations) ** 2 / n
    return m, max(ss, 0.0)


def _need_two(n: int) -> None:
    if n < 2:
        raise StatisticsError(
            f"sample statistics need at least 2 data points, got {n}"
        )


def mean(data: Iterable) -> float:
    """Arithmetic mean."""
    values = _to_floats(data)
    return math.fsum(values) / len(values)


def sum_of_squares(data: Iterable) -> float:
    """Sum of squared deviations from the mean, SS = sum((x - mean)**2)."""
    return _mean_and_ss(_to_floats(data))[1]


def population_variance(data: Iterable) -> float:
    """Population variance, SS / N."""
    values = _to_floats(data)
    return _mean_and_ss(values)[1] / len(values)


def sample_variance(data: Iterable) -> float:
    """Sample variance with Bessel's correction, SS / (n - 1). Needs n >= 2."""
    values = _to_floats(data)
    _need_two(len(values))
    return _mean_and_ss(values)[1] / (len(values) - 1)


def population_stdev(data: Iterable) -> float:
    """Population standard deviation, sqrt(SS / N)."""
    return math.sqrt(population_variance(data))


def sample_stdev(data: Iterable) -> float:
    """Sample standard deviation, sqrt(SS / (n - 1)). Needs n >= 2."""
    return math.sqrt(sample_variance(data))


def coefficient_of_variation(data: Iterable, population: bool = False) -> float:
    """Standard deviation divided by |mean|, as a ratio (0.05 means 5 %).

    Uses the sample standard deviation unless ``population=True``.
    Raises StatisticsError when the mean is zero.
    """
    values = _to_floats(data)
    n = len(values)
    if not population:
        _need_two(n)
    m, ss = _mean_and_ss(values)
    if m == 0:
        raise StatisticsError("mean is zero; relative dispersion is undefined")
    sd = math.sqrt(ss / (n if population else n - 1))
    return sd / abs(m)


def relative_std_dev(data: Iterable, population: bool = False) -> float:
    """Relative standard deviation in percent: 100 * SD / |mean|.

    Uses the sample standard deviation unless ``population=True``.
    Raises StatisticsError when the mean is zero.
    """
    return 100.0 * coefficient_of_variation(data, population=population)


@dataclass(frozen=True)
class Summary:
    """Result of :func:`describe`. ``rsd_percent`` is None when the mean is 0."""

    n: int
    mean: float
    minimum: float
    maximum: float
    range: float
    sum_of_squares: float
    variance: float
    stdev: float
    rsd_percent: Optional[float]
    population: bool

    def as_dict(self) -> dict:
        return asdict(self)


def describe(data: Iterable, population: bool = False) -> Summary:
    """Summary of location and spread.

    ``population=False`` (default) uses n - 1 in the denominator and needs
    at least two values; ``population=True`` uses N.
    """
    values = _to_floats(data)
    n = len(values)
    if not population:
        _need_two(n)
    m, ss = _mean_and_ss(values)
    var = ss / (n if population else n - 1)
    sd = math.sqrt(var)
    lo, hi = min(values), max(values)
    return Summary(
        n=n,
        mean=m,
        minimum=lo,
        maximum=hi,
        range=hi - lo,
        sum_of_squares=ss,
        variance=var,
        stdev=sd,
        rsd_percent=None if m == 0 else 100.0 * (sd / abs(m)),
        population=population,
    )
