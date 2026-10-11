package io.github.rameshxyz.sdtoolkit;

import java.util.OptionalDouble;

/**
 * Mean, variance, standard deviation, coefficient of variation and relative
 * standard deviation.
 *
 * <p>Every method validates its input: empty arrays, NaN and infinities throw
 * {@link StatisticsException}. Variance uses a corrected two-pass algorithm
 * with Neumaier-compensated sums; the shortcut {@code sum(x*x) - n*mean*mean}
 * is never used.
 */
public final class SdToolkit {
    private SdToolkit() {}

    /** Arithmetic mean. */
    public static double mean(double... data) {
        validate(data);
        return sum(data) / data.length;
    }

    /** Sum of squared deviations from the mean, SS = Σ(x − mean)². */
    public static double sumOfSquares(double... data) {
        validate(data);
        return ss(data, sum(data) / data.length);
    }

    /** Population variance, SS / N. */
    public static double populationVariance(double... data) {
        return sumOfSquares(data) / data.length;
    }

    /** Sample variance with Bessel's correction, SS / (n − 1). Needs n ≥ 2. */
    public static double sampleVariance(double... data) {
        validate(data);
        needTwo(data.length);
        return ss(data, sum(data) / data.length) / (data.length - 1);
    }

    /** Population standard deviation, √(SS / N). */
    public static double populationStdev(double... data) {
        return Math.sqrt(populationVariance(data));
    }

    /** Sample standard deviation, √(SS / (n − 1)). Needs n ≥ 2. */
    public static double sampleStdev(double... data) {
        return Math.sqrt(sampleVariance(data));
    }

    /** Sample standard deviation divided by |mean|, as a ratio (0.05 means 5 %). */
    public static double coefficientOfVariation(double... data) {
        return coefficientOfVariation(data, false);
    }

    /**
     * Standard deviation divided by |mean|, as a ratio.
     *
     * @throws StatisticsException when the mean is zero
     */
    public static double coefficientOfVariation(double[] data, boolean population) {
        Summary s = describe(data, population);
        if (s.getMean() == 0) {
            throw new StatisticsException("mean is zero; relative dispersion is undefined");
        }
        return s.getStdev() / Math.abs(s.getMean());
    }

    /** Relative standard deviation in percent (sample): 100 × s / |mean|. */
    public static double relativeStdDev(double... data) {
        return relativeStdDev(data, false);
    }

    /** Relative standard deviation in percent: 100 × SD / |mean|. */
    public static double relativeStdDev(double[] data, boolean population) {
        return 100.0 * coefficientOfVariation(data, population);
    }

    /** Summary using the sample formulas (divisor n − 1). */
    public static Summary describe(double... data) {
        return describe(data, false);
    }

    /** Summary of location and spread; {@code population} selects divisor N instead of n − 1. */
    public static Summary describe(double[] data, boolean population) {
        validate(data);
        int n = data.length;
        if (!population) {
            needTwo(n);
        }
        double m = sum(data) / n;
        double ss = ss(data, m);
        double var = ss / (population ? n : n - 1);
        double sd = Math.sqrt(var);
        double lo = data[0];
        double hi = data[0];
        for (double x : data) {
            lo = Math.min(lo, x);
            hi = Math.max(hi, x);
        }
        OptionalDouble rsd = m == 0 ? OptionalDouble.empty() : OptionalDouble.of(100.0 * (sd / Math.abs(m)));
        return new Summary(n, m, lo, hi, ss, var, sd, rsd, population);
    }

    private static void validate(double[] data) {
        if (data == null || data.length == 0) {
            throw new StatisticsException("no data points: at least one value is required");
        }
        for (int i = 0; i < data.length; i++) {
            if (Double.isNaN(data[i])) {
                throw new StatisticsException("item " + i + ": NaN is not allowed");
            }
            if (Double.isInfinite(data[i])) {
                throw new StatisticsException("item " + i + ": infinity is not allowed");
            }
        }
    }

    private static void needTwo(int n) {
        if (n < 2) {
            throw new StatisticsException("sample statistics need at least 2 data points, got " + n);
        }
    }

    /** Corrected two-pass sum of squares; the second term removes rounding error left in m. */
    private static double ss(double[] data, double m) {
        double[] d = new double[data.length];
        double[] d2 = new double[data.length];
        for (int i = 0; i < data.length; i++) {
            d[i] = data[i] - m;
            d2[i] = d[i] * d[i];
        }
        double c = sum(d);
        return Math.max(sum(d2) - c * c / data.length, 0.0);
    }

    /** Neumaier compensated summation. */
    private static double sum(double[] values) {
        double s = 0.0;
        double comp = 0.0;
        for (double x : values) {
            double t = s + x;
            comp += Math.abs(s) >= Math.abs(x) ? (s - t) + x : (x - t) + s;
            s = t;
        }
        return s + comp;
    }
}
