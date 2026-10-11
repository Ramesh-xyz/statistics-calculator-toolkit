/// Dispersion statistics: mean, variance, standard deviation, coefficient of
/// variation and relative standard deviation.
///
/// Variance uses the corrected two-pass algorithm with Neumaier-compensated
/// sums. Invalid input throws [StatisticsException].
library;

import 'dart:math' as math;

/// Thrown for empty, too-short or invalid input, and for CV/RSD with a zero
/// mean.
class StatisticsException implements Exception {
  /// Description of the problem.
  final String message;

  /// Creates an exception with [message].
  const StatisticsException(this.message);

  @override
  String toString() => 'StatisticsException: $message';
}

List<double> _toDoubles(Iterable<num> data) {
  final values = <double>[];
  var i = 0;
  for (final x in data) {
    final f = x.toDouble();
    if (f.isNaN) throw StatisticsException('item $i: NaN is not allowed');
    if (f.isInfinite) {
      throw StatisticsException('item $i: infinity is not allowed');
    }
    values.add(f);
    i++;
  }
  if (values.isEmpty) {
    throw const StatisticsException(
        'no data points: at least one value is required');
  }
  return values;
}

/// Neumaier compensated summation.
double _sum(Iterable<double> values) {
  var s = 0.0;
  var c = 0.0;
  for (final x in values) {
    final t = s + x;
    c += s.abs() >= x.abs() ? (s - t) + x : (x - t) + s;
    s = t;
  }
  return s + c;
}

(double, double) _meanAndSS(List<double> values) {
  final n = values.length;
  final m = _sum(values) / n;
  final d = [for (final x in values) x - m];
  final dsum = _sum(d);
  final ss = _sum(d.map((v) => v * v)) - dsum * dsum / n;
  return (m, math.max(ss, 0.0));
}

void _needTwo(int n) {
  if (n < 2) {
    throw StatisticsException(
        'sample statistics need at least 2 data points, got $n');
  }
}

/// Arithmetic mean.
double mean(Iterable<num> data) {
  final values = _toDoubles(data);
  return _sum(values) / values.length;
}

/// Sum of squared deviations from the mean, SS = Σ(x − x̄)².
double sumOfSquares(Iterable<num> data) => _meanAndSS(_toDoubles(data)).$2;

/// Population variance, SS / N.
double populationVariance(Iterable<num> data) {
  final values = _toDoubles(data);
  return _meanAndSS(values).$2 / values.length;
}

/// Sample variance, SS / (n − 1). Needs at least 2 values.
double sampleVariance(Iterable<num> data) {
  final values = _toDoubles(data);
  _needTwo(values.length);
  return _meanAndSS(values).$2 / (values.length - 1);
}

/// Population standard deviation, √(SS / N).
double populationStdev(Iterable<num> data) =>
    math.sqrt(populationVariance(data));

/// Sample standard deviation, √(SS / (n − 1)). Needs at least 2 values.
double sampleStdev(Iterable<num> data) => math.sqrt(sampleVariance(data));

/// Standard deviation divided by |mean|, as a ratio (0.05 means 5 %).
///
/// Uses the sample standard deviation unless [population] is true. Throws
/// when the mean is zero.
double coefficientOfVariation(Iterable<num> data, {bool population = false}) {
  final values = _toDoubles(data);
  final n = values.length;
  if (!population) _needTwo(n);
  final (m, ss) = _meanAndSS(values);
  if (m == 0) {
    throw const StatisticsException(
        'mean is zero; relative dispersion is undefined');
  }
  return math.sqrt(ss / (population ? n : n - 1)) / m.abs();
}

/// Relative standard deviation in percent: 100 × SD / |mean|.
///
/// Uses the sample standard deviation unless [population] is true. Throws
/// when the mean is zero.
double relativeStdDev(Iterable<num> data, {bool population = false}) =>
    100 * coefficientOfVariation(data, population: population);

/// Result of [describe].
class Summary {
  /// Number of values.
  final int n;

  /// Arithmetic mean.
  final double mean;

  /// Smallest value.
  final double minimum;

  /// Largest value.
  final double maximum;

  /// maximum − minimum.
  final double range;

  /// Σ(x − x̄)².
  final double sumOfSquares;

  /// Population or sample variance, depending on [population].
  final double variance;

  /// Population or sample standard deviation, depending on [population].
  final double stdev;

  /// Relative standard deviation in percent; null when the mean is zero.
  final double? rsdPercent;

  /// Whether the population formulas (divide by N) were used.
  final bool population;

  /// Creates a summary. Normally obtained from [describe].
  const Summary({
    required this.n,
    required this.mean,
    required this.minimum,
    required this.maximum,
    required this.range,
    required this.sumOfSquares,
    required this.variance,
    required this.stdev,
    required this.rsdPercent,
    required this.population,
  });

  @override
  String toString() => 'Summary(n: $n, mean: $mean, minimum: $minimum, '
      'maximum: $maximum, range: $range, sumOfSquares: $sumOfSquares, '
      'variance: $variance, stdev: $stdev, rsdPercent: $rsdPercent, '
      'population: $population)';
}

/// Summary of location and spread.
///
/// [population] false (default) divides by n − 1 and needs at least two
/// values; true divides by N.
Summary describe(Iterable<num> data, {bool population = false}) {
  final values = _toDoubles(data);
  final n = values.length;
  if (!population) _needTwo(n);
  final (m, ss) = _meanAndSS(values);
  final variance = ss / (population ? n : n - 1);
  final stdev = math.sqrt(variance);
  final lo = values.reduce(math.min);
  final hi = values.reduce(math.max);
  return Summary(
    n: n,
    mean: m,
    minimum: lo,
    maximum: hi,
    range: hi - lo,
    sumOfSquares: ss,
    variance: variance,
    stdev: stdev,
    rsdPercent: m == 0 ? null : 100 * (stdev / m.abs()),
    population: population,
  );
}
