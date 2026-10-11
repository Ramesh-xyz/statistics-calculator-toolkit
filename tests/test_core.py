import io
import math
import os
import re
import statistics
import subprocess
import sys
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from decimal import Decimal
from fractions import Fraction

import sdtoolkit as sd
from sdtoolkit.cli import main

HERE = os.path.dirname(os.path.abspath(__file__))
EXAMPLES_CSV = os.path.join(HERE, "..", "examples", "sample-datasets.csv")

DATASETS = {
    "classic": [2, 4, 4, 4, 5, 5, 7, 9],
    "floats": [12.41, 12.38, 12.45, 12.40, 12.36, 12.43, 12.39, 12.44, 12.37, 12.42],
    "negatives": [-3.5, -1.25, 0.0, 2.75, -8.0, 4.5],
    "large_offset": [1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16],
    "huge_offset": [1e12 + 0.1, 1e12 + 0.2, 1e12 + 0.3],
    "tiny": [1e-9, 2e-9, 3e-9, 4e-9],
    "two_points": [10, 20],
}


class TestAgainstStatisticsModule(unittest.TestCase):
    def assertClose(self, a, b):
        self.assertTrue(
            math.isclose(a, b, rel_tol=1e-12, abs_tol=1e-300),
            msg=f"{a!r} != {b!r}",
        )

    def test_matches_stdlib(self):
        for name, data in DATASETS.items():
            with self.subTest(dataset=name):
                floats = [float(x) for x in data]
                self.assertClose(sd.mean(data), statistics.fmean(floats))
                self.assertClose(sd.population_variance(data), statistics.pvariance(floats))
                self.assertClose(sd.sample_variance(data), statistics.variance(floats))
                self.assertClose(sd.population_stdev(data), statistics.pstdev(floats))
                self.assertClose(sd.sample_stdev(data), statistics.stdev(floats))

    def test_large_offset_exact(self):
        data = DATASETS["large_offset"]
        self.assertEqual(sd.sum_of_squares(data), 90.0)
        self.assertEqual(sd.population_variance(data), 22.5)
        self.assertEqual(sd.sample_variance(data), 30.0)

    def test_naive_formula_would_fail_here(self):
        # Shows why the shortcut formula is avoided: it is badly wrong on this data.
        data = [1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16]
        n = len(data)
        naive = (sum(x * x for x in data) - sum(data) ** 2 / n) / (n - 1)
        self.assertNotAlmostEqual(naive, 30.0, places=3)
        self.assertEqual(sd.sample_variance(data), 30.0)


class TestKnownValues(unittest.TestCase):
    def test_classic(self):
        data = [2, 4, 4, 4, 5, 5, 7, 9]
        self.assertEqual(sd.mean(data), 5.0)
        self.assertEqual(sd.sum_of_squares(data), 32.0)
        self.assertEqual(sd.population_variance(data), 4.0)
        self.assertEqual(sd.population_stdev(data), 2.0)
        self.assertAlmostEqual(sd.sample_variance(data), 32 / 7, places=15)
        self.assertAlmostEqual(sd.sample_stdev(data), 2.138089935299395, places=15)

    def test_rsd_and_cv(self):
        data = [2, 4, 4, 4, 5, 5, 7, 9]
        self.assertAlmostEqual(sd.coefficient_of_variation(data), 2.138089935299395 / 5)
        self.assertAlmostEqual(sd.relative_std_dev(data), 42.7617987059879)
        self.assertEqual(sd.relative_std_dev(data, population=True), 40.0)

    def test_rsd_uses_absolute_mean(self):
        self.assertEqual(sd.relative_std_dev([-2, -4, -6], population=True),
                         sd.relative_std_dev([2, 4, 6], population=True))

    def test_constant_data(self):
        data = [3.3] * 5
        self.assertEqual(sd.sample_variance(data), 0.0)
        self.assertEqual(sd.relative_std_dev(data), 0.0)

    def test_single_value_population(self):
        self.assertEqual(sd.population_variance([7]), 0.0)

    def test_generator_input(self):
        self.assertEqual(sd.mean(x for x in [1, 2, 3]), 2.0)

    def test_decimal_and_fraction(self):
        self.assertEqual(sd.mean([Decimal("1.5"), Fraction(5, 2)]), 2.0)
        self.assertEqual(sd.population_variance([Decimal("1"), Decimal("3")]), 1.0)

    def test_describe(self):
        s = sd.describe([2, 4, 4, 4, 5, 5, 7, 9], population=True)
        self.assertEqual((s.n, s.mean, s.variance, s.stdev, s.rsd_percent), (8, 5.0, 4.0, 2.0, 40.0))
        self.assertEqual((s.minimum, s.maximum, s.range), (2.0, 9.0, 7.0))
        self.assertEqual(s.as_dict()["sum_of_squares"], 32.0)
        self.assertFalse(sd.describe([1, 2]).population)

    def test_describe_zero_mean(self):
        self.assertIsNone(sd.describe([-1, 1]).rsd_percent)


class TestValidation(unittest.TestCase):
    def test_error_is_value_error(self):
        self.assertTrue(issubclass(sd.StatisticsError, ValueError))

    def test_empty(self):
        for fn in (sd.mean, sd.sum_of_squares, sd.population_variance, sd.population_stdev):
            with self.assertRaisesRegex(sd.StatisticsError, "no data points"):
                fn([])

    def test_sample_needs_two(self):
        for fn in (sd.sample_variance, sd.sample_stdev, sd.relative_std_dev):
            with self.assertRaisesRegex(sd.StatisticsError, "at least 2"):
                fn([5])
        with self.assertRaises(sd.StatisticsError):
            sd.describe([5])

    def test_zero_mean(self):
        with self.assertRaisesRegex(sd.StatisticsError, "mean is zero"):
            sd.relative_std_dev([-1, 1])
        with self.assertRaisesRegex(sd.StatisticsError, "mean is zero"):
            sd.coefficient_of_variation([-2, 0, 2], population=True)

    def test_bad_items(self):
        cases = {
            "booleans": [1, True, 3],
            "None": [1, None, 3],
            "NaN": [1, float("nan")],
            "infinity": [1, float("inf")],
            "strings are not accepted": [1, "abc"],
            "not a real number": [1, 2j],
            "too large": [1, 10**400],
        }
        for msg, data in cases.items():
            with self.subTest(msg=msg):
                with self.assertRaisesRegex(sd.StatisticsError, msg):
                    sd.mean(data)

    def test_string_input(self):
        with self.assertRaisesRegex(sd.StatisticsError, "got a string"):
            sd.mean("123")

    def test_decimal_nan(self):
        with self.assertRaisesRegex(sd.StatisticsError, "NaN"):
            sd.mean([Decimal("NaN")])


def run_cli(*args):
    out, err = io.StringIO(), io.StringIO()
    with redirect_stdout(out), redirect_stderr(err):
        code = main(list(args))
    return code, out.getvalue(), err.getvalue()


def fields(out):
    """Parse the summary table into {label: value}."""
    return dict(re.split(r"\s{2,}", line, maxsplit=1) for line in out.splitlines()[:-1])


class TestCLI(unittest.TestCase):
    def test_values_sample(self):
        code, out, _ = run_cli("2", "4", "4", "4", "5", "5", "7", "9")
        self.assertEqual(code, 0)
        f = fields(out)
        self.assertEqual(f["sample variance"], "4.571428571")
        self.assertEqual(f["sample std dev"], "2.138089935")
        self.assertIn("(divisor: n - 1)", out)

    def test_population(self):
        code, out, _ = run_cli("--population", "2", "4", "4", "4", "5", "5", "7", "9")
        self.assertEqual(code, 0)
        self.assertEqual(fields(out)["population std dev"], "2")

    def test_negative_numbers(self):
        code, out, _ = run_cli("-1", "-3")
        self.assertEqual(code, 0)
        self.assertEqual(fields(out)["mean"], "-2")

    def test_csv(self):
        code, out, _ = run_cli("--csv", EXAMPLES_CSV, "--column", "exam_score")
        self.assertEqual(code, 0)
        f = fields(out)
        self.assertEqual((f["n"], f["mean"], f["sample variance"]), ("10", "77.4", "79.6"))

    def test_csv_missing_value_not_skipped(self):
        with tempfile.NamedTemporaryFile("w", suffix=".csv", delete=False) as f:
            f.write("x\n1\n\n3\n,\n")
            path = f.name
        try:
            code, _, err = run_cli("--csv", path, "--column", "x")
        finally:
            os.unlink(path)
        self.assertEqual(code, 1)
        self.assertIn("empty cell", err)

    def test_csv_unknown_column(self):
        code, _, err = run_cli("--csv", EXAMPLES_CSV, "--column", "nope")
        self.assertEqual(code, 1)
        self.assertIn("not found", err)

    def test_bad_value(self):
        code, _, err = run_cli("1", "two")
        self.assertEqual(code, 1)
        self.assertIn("'two' is not a number", err)

    def test_nan_value(self):
        code, _, err = run_cli("1", "nan")
        self.assertEqual(code, 1)
        self.assertIn("NaN", err)

    def test_single_sample_value(self):
        code, _, err = run_cli("5")
        self.assertEqual(code, 1)
        self.assertIn("at least 2", err)

    def test_usage_errors(self):
        for args in ([], ["--csv", EXAMPLES_CSV], ["1", "--csv", EXAMPLES_CSV, "--column", "x"]):
            with self.subTest(args=args):
                with redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                    main(args)

    def test_python_dash_m(self):
        env = dict(os.environ)
        src = os.path.join(HERE, "..", "src")
        env["PYTHONPATH"] = src + os.pathsep + env.get("PYTHONPATH", "")
        r = subprocess.run(
            [sys.executable, "-m", "sdtoolkit", "--population", "1", "2", "3", "4"],
            capture_output=True, text=True, env=env,
        )
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(fields(r.stdout)["population variance"], "1.25")


if __name__ == "__main__":
    unittest.main()
