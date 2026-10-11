"""Command-line interface: ``python -m sdtoolkit 2 4 4 4 5 5 7 9``."""

import argparse
import csv
import sys
from typing import List, Optional

from .core import StatisticsError, describe


def _parse_number(text: str, where: str) -> float:
    try:
        return float(text)
    except ValueError:
        raise StatisticsError(f"{where}: {text!r} is not a number") from None


def _read_column(path: str, column: str) -> List[float]:
    with open(path, newline="", encoding="utf-8") as f:
        # Lines starting with '#' are comments.
        reader = csv.DictReader(line for line in f if not line.startswith("#"))
        if reader.fieldnames is None or column not in reader.fieldnames:
            raise StatisticsError(
                f"column {column!r} not found; available: {reader.fieldnames}"
            )
        values = []
        for i, row in enumerate(reader, start=1):
            cell = (row[column] or "").strip()
            if not cell:
                raise StatisticsError(
                    f"{path}: data row {i}: empty cell in {column!r} "
                    "(missing values are not skipped)"
                )
            values.append(_parse_number(cell, f"{path}: data row {i}"))
    return values


def _fmt(x: float) -> str:
    return f"{x:.10g}"


def format_summary(s) -> str:
    kind = "population" if s.population else "sample"
    denom = "N" if s.population else "n - 1"
    rows = [
        ("n", str(s.n)),
        ("mean", _fmt(s.mean)),
        ("min", _fmt(s.minimum)),
        ("max", _fmt(s.maximum)),
        ("range", _fmt(s.range)),
        ("sum of squares", _fmt(s.sum_of_squares)),
        (f"{kind} variance", _fmt(s.variance)),
        (f"{kind} std dev", _fmt(s.stdev)),
        ("RSD (%)", "undefined (mean is 0)" if s.rsd_percent is None else _fmt(s.rsd_percent)),
    ]
    width = max(len(k) for k, _ in rows)
    lines = [f"{k:<{width}}  {v}" for k, v in rows]
    lines.append(f"(divisor: {denom})")
    return "\n".join(lines)


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        prog="sdtoolkit",
        description="Mean, variance, standard deviation and RSD of a dataset.",
    )
    parser.add_argument("values", nargs="*", help="numbers to summarise")
    parser.add_argument(
        "--population", action="store_true",
        help="treat data as the whole population (divide by N, not n - 1)",
    )
    parser.add_argument("--csv", metavar="FILE", help="read values from a CSV file")
    parser.add_argument("--column", metavar="NAME", help="CSV column to use (with --csv)")
    args = parser.parse_args(argv)

    if args.csv and args.values:
        parser.error("give either values or --csv, not both")
    if bool(args.csv) != bool(args.column):
        parser.error("--csv and --column must be used together")
    if not args.csv and not args.values:
        parser.error("no values given")

    try:
        if args.csv:
            data = _read_column(args.csv, args.column)
        else:
            data = [_parse_number(v, f"argument {i + 1}") for i, v in enumerate(args.values)]
        summary = describe(data, population=args.population)
    except (StatisticsError, OSError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    print(format_summary(summary))
    return 0
