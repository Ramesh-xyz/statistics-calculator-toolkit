"""sdtoolkit: dependency-free standard deviation, variance and RSD."""

from .core import (
    StatisticsError,
    Summary,
    coefficient_of_variation,
    describe,
    mean,
    population_stdev,
    population_variance,
    relative_std_dev,
    sample_stdev,
    sample_variance,
    sum_of_squares,
)

__version__ = "0.1.0"

__all__ = [
    "StatisticsError",
    "Summary",
    "coefficient_of_variation",
    "describe",
    "mean",
    "population_stdev",
    "population_variance",
    "relative_std_dev",
    "sample_stdev",
    "sample_variance",
    "sum_of_squares",
]
