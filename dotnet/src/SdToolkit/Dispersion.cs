using System;
using System.Collections.Generic;
using System.Linq;

namespace SdToolkit;

/// <summary>Thrown for empty, too-short or invalid input, or a zero mean in relative statistics.</summary>
public sealed class StatisticsException : ArgumentException
{
    /// <summary>Creates the exception with a message.</summary>
    public StatisticsException(string message) : base(message) { }
}

/// <summary>Result of <see cref="Dispersion.Describe"/>.</summary>
/// <param name="N">Number of values.</param>
/// <param name="Mean">Arithmetic mean.</param>
/// <param name="Minimum">Smallest value.</param>
/// <param name="Maximum">Largest value.</param>
/// <param name="Range">Maximum minus minimum.</param>
/// <param name="SumOfSquares">Σ(x − mean)².</param>
/// <param name="Variance">SS / N or SS / (n − 1).</param>
/// <param name="Stdev">Square root of the variance.</param>
/// <param name="RsdPercent">Relative standard deviation in percent; null when the mean is zero.</param>
/// <param name="Population">True when divisor N was used.</param>
public sealed record Summary(
    int N, double Mean, double Minimum, double Maximum, double Range,
    double SumOfSquares, double Variance, double Stdev, double? RsdPercent, bool Population);

/// <summary>
/// Mean, variance, standard deviation, coefficient of variation and relative standard deviation.
/// Variance uses a corrected two-pass algorithm with Neumaier-compensated sums.
/// </summary>
public static class Dispersion
{
    /// <summary>Arithmetic mean.</summary>
    public static double Mean(IEnumerable<double> data)
    {
        var v = Validate(data);
        return Sum(v) / v.Length;
    }

    /// <summary>Sum of squared deviations from the mean, SS = Σ(x − mean)².</summary>
    public static double SumOfSquares(IEnumerable<double> data)
    {
        var v = Validate(data);
        return Ss(v, Sum(v) / v.Length);
    }

    /// <summary>Population variance, SS / N.</summary>
    public static double PopulationVariance(IEnumerable<double> data) => Describe(data, population: true).Variance;

    /// <summary>Sample variance with Bessel's correction, SS / (n − 1). Needs n ≥ 2.</summary>
    public static double SampleVariance(IEnumerable<double> data) => Describe(data).Variance;

    /// <summary>Population standard deviation, √(SS / N).</summary>
    public static double PopulationStdev(IEnumerable<double> data) => Describe(data, population: true).Stdev;

    /// <summary>Sample standard deviation, √(SS / (n − 1)). Needs n ≥ 2.</summary>
    public static double SampleStdev(IEnumerable<double> data) => Describe(data).Stdev;

    /// <summary>Standard deviation divided by |mean|, as a ratio (0.05 means 5 %).</summary>
    /// <exception cref="StatisticsException">The mean is zero.</exception>
    public static double CoefficientOfVariation(IEnumerable<double> data, bool population = false)
    {
        var s = Describe(data, population);
        if (s.Mean == 0)
            throw new StatisticsException("mean is zero; relative dispersion is undefined");
        return s.Stdev / Math.Abs(s.Mean);
    }

    /// <summary>Relative standard deviation in percent: 100 × SD / |mean|.</summary>
    /// <exception cref="StatisticsException">The mean is zero.</exception>
    public static double RelativeStdDev(IEnumerable<double> data, bool population = false) =>
        100.0 * CoefficientOfVariation(data, population);

    /// <summary>Summary of location and spread. <paramref name="population"/> selects divisor N instead of n − 1.</summary>
    public static Summary Describe(IEnumerable<double> data, bool population = false)
    {
        var v = Validate(data);
        int n = v.Length;
        if (!population && n < 2)
            throw new StatisticsException($"sample statistics need at least 2 data points, got {n}");
        double m = Sum(v) / n;
        double ss = Ss(v, m);
        double variance = ss / (population ? n : n - 1);
        double sd = Math.Sqrt(variance);
        double lo = v.Min(), hi = v.Max();
        return new Summary(n, m, lo, hi, hi - lo, ss, variance, sd,
            m == 0 ? null : 100.0 * (sd / Math.Abs(m)), population);
    }

    private static double[] Validate(IEnumerable<double> data)
    {
        if (data is null)
            throw new StatisticsException("no data points: at least one value is required");
        var v = data.ToArray();
        if (v.Length == 0)
            throw new StatisticsException("no data points: at least one value is required");
        for (int i = 0; i < v.Length; i++)
        {
            if (double.IsNaN(v[i]))
                throw new StatisticsException($"item {i}: NaN is not allowed");
            if (double.IsInfinity(v[i]))
                throw new StatisticsException($"item {i}: infinity is not allowed");
        }
        return v;
    }

    // Corrected two-pass: Σd is zero in exact arithmetic; subtracting (Σd)²/n removes rounding error left in m.
    private static double Ss(double[] v, double m)
    {
        var d = v.Select(x => x - m).ToArray();
        double c = Sum(d);
        return Math.Max(Sum(d.Select(x => x * x)) - c * c / v.Length, 0.0);
    }

    // Neumaier compensated summation.
    private static double Sum(IEnumerable<double> values)
    {
        double s = 0.0, comp = 0.0;
        foreach (var x in values)
        {
            double t = s + x;
            comp += Math.Abs(s) >= Math.Abs(x) ? (s - t) + x : (x - t) + s;
            s = t;
        }
        return s + comp;
    }
}
