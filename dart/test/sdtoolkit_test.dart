import 'package:sdtoolkit/sdtoolkit.dart' as sd;
import 'package:test/test.dart';

const classic = [2, 4, 4, 4, 5, 5, 7, 9];
const offset = [1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16];

Matcher throwsWith(String text) => throwsA(isA<sd.StatisticsException>()
    .having((e) => e.message, 'message', contains(text)));

void main() {
  test('classic dataset', () {
    expect(sd.mean(classic), 5);
    expect(sd.sumOfSquares(classic), 32);
    expect(sd.populationVariance(classic), 4);
    expect(sd.populationStdev(classic), 2);
    expect(sd.sampleVariance(classic), closeTo(32 / 7, 1e-12));
    expect(sd.sampleStdev(classic), closeTo(2.138089935299395, 1e-12));
    expect(sd.relativeStdDev(classic), closeTo(42.7617987059879, 1e-10));
    expect(sd.relativeStdDev(classic, population: true), 40);
    expect(sd.coefficientOfVariation(classic),
        closeTo(2.138089935299395 / 5, 1e-12));
  });

  test('large offset is exact', () {
    expect(sd.sumOfSquares(offset), 90);
    expect(sd.sampleVariance(offset), 30);
  });

  test('negative mean uses |mean|', () {
    expect(sd.relativeStdDev([-2, -4, -6], population: true),
        sd.relativeStdDev([2, 4, 6], population: true));
  });

  test('single value', () {
    expect(sd.populationVariance([7]), 0);
    expect(sd.populationStdev([7]), 0);
    expect(() => sd.sampleVariance([5]), throwsWith('at least 2'));
    expect(() => sd.sampleStdev([5]), throwsWith('at least 2'));
    expect(() => sd.relativeStdDev([5]), throwsWith('at least 2'));
    expect(() => sd.describe([5]), throwsWith('at least 2'));
  });

  test('zero mean', () {
    expect(() => sd.relativeStdDev([-1, 1]), throwsWith('mean is zero'));
    expect(() => sd.coefficientOfVariation([-2, 0, 2], population: true),
        throwsWith('mean is zero'));
    expect(sd.describe([-1, 1]).rsdPercent, isNull);
  });

  test('describe', () {
    final s = sd.describe(classic, population: true);
    expect([s.n, s.mean, s.minimum, s.maximum, s.range, s.sumOfSquares],
        [8, 5, 2, 9, 7, 32]);
    expect([s.variance, s.stdev, s.rsdPercent], [4, 2, 40]);
    expect(s.population, isTrue);
    expect(sd.describe([1, 2]).population, isFalse);
  });

  test('invalid input', () {
    expect(() => sd.mean([]), throwsWith('no data points'));
    expect(() => sd.mean([1, double.nan]), throwsWith('item 1: NaN'));
    expect(() => sd.mean([1, double.infinity]), throwsWith('infinity'));
    expect(() => sd.mean([1, double.negativeInfinity]), throwsWith('infinity'));
  });
}
