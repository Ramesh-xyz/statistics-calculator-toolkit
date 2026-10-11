using System;
using System.Linq;
using SdToolkit;
using Xunit;

public class DispersionTests
{
    static readonly double[] Classic = { 2, 4, 4, 4, 5, 5, 7, 9 };
    static readonly double[] LargeOffset = { 1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16 };

    static void AssertError(string fragment, Action call)
    {
        var e = Assert.Throws<StatisticsException>(call);
        Assert.Contains(fragment, e.Message);
    }

    [Fact]
    public void ClassicValues()
    {
        Assert.Equal(5.0, Dispersion.Mean(Classic));
        Assert.Equal(32.0, Dispersion.SumOfSquares(Classic));
        Assert.Equal(4.0, Dispersion.PopulationVariance(Classic));
        Assert.Equal(2.0, Dispersion.PopulationStdev(Classic));
        Assert.Equal(32.0 / 7, Dispersion.SampleVariance(Classic), 1e-15);
        Assert.Equal(2.138089935299395, Dispersion.SampleStdev(Classic), 1e-15);
        Assert.Equal(42.7617987059879, Dispersion.RelativeStdDev(Classic), 1e-12);
        Assert.Equal(40.0, Dispersion.RelativeStdDev(Classic, population: true), 1e-12);
        Assert.Equal(0.4, Dispersion.CoefficientOfVariation(Classic, population: true), 1e-15);
    }

    [Fact]
    public void LargeOffsetIsExact()
    {
        Assert.Equal(90.0, Dispersion.SumOfSquares(LargeOffset));
        Assert.Equal(30.0, Dispersion.SampleVariance(LargeOffset));
    }

    [Fact]
    public void NegativeMeanUsesAbsoluteValue() =>
        Assert.Equal(Dispersion.RelativeStdDev(new double[] { 2, 4, 6 }, true),
                     Dispersion.RelativeStdDev(new double[] { -2, -4, -6 }, true));

    [Fact]
    public void SingleValue()
    {
        Assert.Equal(0.0, Dispersion.PopulationVariance(new double[] { 7 }));
        Assert.Equal(0.0, Dispersion.PopulationStdev(new double[] { 7 }));
        AssertError("at least 2", () => Dispersion.SampleVariance(new double[] { 7 }));
        AssertError("at least 2", () => Dispersion.SampleStdev(new double[] { 7 }));
        AssertError("at least 2", () => Dispersion.RelativeStdDev(new double[] { 7 }));
        AssertError("at least 2", () => Dispersion.Describe(new double[] { 7 }));
    }

    [Fact]
    public void Empty()
    {
        AssertError("no data points", () => Dispersion.Mean(Array.Empty<double>()));
        AssertError("no data points", () => Dispersion.PopulationVariance(Array.Empty<double>()));
        AssertError("no data points", () => Dispersion.Mean(null!));
    }

    [Fact]
    public void NonFinite()
    {
        AssertError("item 1: NaN", () => Dispersion.Mean(new[] { 1, double.NaN }));
        AssertError("item 1: infinity", () => Dispersion.Mean(new[] { 1, double.PositiveInfinity }));
        AssertError("infinity", () => Dispersion.SampleStdev(new[] { double.NegativeInfinity, 1 }));
    }

    [Fact]
    public void ZeroMean()
    {
        AssertError("mean is zero", () => Dispersion.RelativeStdDev(new double[] { -1, 1 }));
        AssertError("mean is zero", () => Dispersion.CoefficientOfVariation(new double[] { -2, 0, 2 }, true));
        Assert.Null(Dispersion.Describe(new double[] { -1, 1 }).RsdPercent);
    }

    [Fact]
    public void Describe()
    {
        var s = Dispersion.Describe(Classic, population: true);
        Assert.Equal(new Summary(8, 5.0, 2.0, 9.0, 7.0, 32.0, 4.0, 2.0, 40.0, true), s);
        Assert.False(Dispersion.Describe(new double[] { 1, 2 }).Population);
    }

    [Fact]
    public void ConstantData()
    {
        var data = new[] { 3.3, 3.3, 3.3, 3.3, 3.3 };
        Assert.Equal(0.0, Dispersion.SampleVariance(data));
        Assert.Equal(0.0, Dispersion.RelativeStdDev(data));
    }

    [Fact]
    public void AcceptsLazySequence()
    {
        Assert.Equal(2.0, Dispersion.Mean(Enumerable.Range(1, 3).Select(i => (double)i)));
    }
}
