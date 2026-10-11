<?php

declare(strict_types=1);

namespace RameshXyz\SdToolkit;

/**
 * Standard deviation, variance, sum of squares, relative standard deviation
 * and coefficient of variation.
 *
 * Every method takes an iterable of int or float values. null, booleans,
 * strings (including numeric strings), NaN and infinities throw
 * StatisticsException. Variance uses a corrected two-pass algorithm with
 * Neumaier compensated summation.
 */
final class Dispersion
{
    private function __construct()
    {
    }

    /** Arithmetic mean. */
    public static function mean(iterable $data): float
    {
        $values = self::toFloats($data);
        return self::sum($values) / count($values);
    }

    /** Sum of squared deviations from the mean, SS = Σ(x − mean)². */
    public static function sumOfSquares(iterable $data): float
    {
        return self::meanAndSs(self::toFloats($data))[1];
    }

    /** Population variance, SS / N. */
    public static function populationVariance(iterable $data): float
    {
        $values = self::toFloats($data);
        return self::meanAndSs($values)[1] / count($values);
    }

    /** Sample variance with Bessel's correction, SS / (n − 1). Needs n ≥ 2. */
    public static function sampleVariance(iterable $data): float
    {
        $values = self::toFloats($data);
        self::needTwo(count($values));
        return self::meanAndSs($values)[1] / (count($values) - 1);
    }

    /** Population standard deviation, √(SS / N). */
    public static function populationStdev(iterable $data): float
    {
        return sqrt(self::populationVariance($data));
    }

    /** Sample standard deviation, √(SS / (n − 1)). Needs n ≥ 2. */
    public static function sampleStdev(iterable $data): float
    {
        return sqrt(self::sampleVariance($data));
    }

    /**
     * Standard deviation divided by |mean|, as a ratio (0.05 means 5 %).
     * Throws when the mean is zero.
     */
    public static function coefficientOfVariation(iterable $data, bool $population = false): float
    {
        $values = self::toFloats($data);
        $n = count($values);
        if (!$population) {
            self::needTwo($n);
        }
        [$m, $ss] = self::meanAndSs($values);
        if ($m == 0.0) {
            throw new StatisticsException('mean is zero; relative dispersion is undefined');
        }
        return sqrt($ss / ($population ? $n : $n - 1)) / abs($m);
    }

    /** Relative standard deviation in percent: 100 × SD / |mean|. */
    public static function relativeStdDev(iterable $data, bool $population = false): float
    {
        return 100.0 * self::coefficientOfVariation($data, $population);
    }

    /** Summary of location and spread. $population = false uses n − 1. */
    public static function describe(iterable $data, bool $population = false): Summary
    {
        $values = self::toFloats($data);
        $n = count($values);
        if (!$population) {
            self::needTwo($n);
        }
        [$m, $ss] = self::meanAndSs($values);
        $var = $ss / ($population ? $n : $n - 1);
        $sd = sqrt($var);
        $lo = min($values);
        $hi = max($values);
        return new Summary(
            n: $n,
            mean: $m,
            minimum: $lo,
            maximum: $hi,
            range: $hi - $lo,
            sumOfSquares: $ss,
            variance: $var,
            stdev: $sd,
            rsdPercent: $m == 0.0 ? null : 100.0 * ($sd / abs($m)),
            population: $population,
        );
    }

    /** @return list<float> */
    private static function toFloats(iterable $data): array
    {
        $values = [];
        $i = 0;
        foreach ($data as $x) {
            if ($x === null) {
                throw new StatisticsException("item $i: null (missing value); remove or fill it before computing");
            }
            if (is_bool($x)) {
                throw new StatisticsException("item $i: booleans are not numbers");
            }
            if (is_string($x)) {
                throw new StatisticsException("item $i: strings are not accepted ('$x'); cast to float first");
            }
            if (!is_int($x) && !is_float($x)) {
                throw new StatisticsException("item $i: " . get_debug_type($x) . ' is not a real number');
            }
            $f = (float) $x;
            if (is_nan($f)) {
                throw new StatisticsException("item $i: NaN is not allowed");
            }
            if (is_infinite($f)) {
                throw new StatisticsException("item $i: infinity is not allowed");
            }
            $values[] = $f;
            $i++;
        }
        if ($values === []) {
            throw new StatisticsException('no data points: at least one value is required');
        }
        return $values;
    }

    /** Neumaier compensated summation. */
    private static function sum(array $values): float
    {
        $sum = 0.0;
        $c = 0.0;
        foreach ($values as $x) {
            $t = $sum + $x;
            $c += abs($sum) >= abs($x) ? ($sum - $t) + $x : ($x - $t) + $sum;
            $sum = $t;
        }
        return $sum + $c;
    }

    /** @return array{float, float} */
    private static function meanAndSs(array $values): array
    {
        $n = count($values);
        $m = self::sum($values) / $n;
        $d = array_map(static fn (float $x): float => $x - $m, $values);
        $ss = self::sum(array_map(static fn (float $v): float => $v * $v, $d)) - self::sum($d) ** 2 / $n;
        return [$m, max($ss, 0.0)];
    }

    private static function needTwo(int $n): void
    {
        if ($n < 2) {
            throw new StatisticsException("sample statistics need at least 2 data points, got $n");
        }
    }
}
