package io.github.rameshxyz.sdtoolkit;

import java.util.OptionalDouble;

/** Result of {@link SdToolkit#describe(double[], boolean)}. */
public final class Summary {
    private final int n;
    private final double mean;
    private final double minimum;
    private final double maximum;
    private final double sumOfSquares;
    private final double variance;
    private final double stdev;
    private final OptionalDouble rsdPercent;
    private final boolean population;

    Summary(int n, double mean, double minimum, double maximum, double sumOfSquares,
            double variance, double stdev, OptionalDouble rsdPercent, boolean population) {
        this.n = n;
        this.mean = mean;
        this.minimum = minimum;
        this.maximum = maximum;
        this.sumOfSquares = sumOfSquares;
        this.variance = variance;
        this.stdev = stdev;
        this.rsdPercent = rsdPercent;
        this.population = population;
    }

    public int getN() { return n; }
    public double getMean() { return mean; }
    public double getMinimum() { return minimum; }
    public double getMaximum() { return maximum; }
    public double getRange() { return maximum - minimum; }
    public double getSumOfSquares() { return sumOfSquares; }
    public double getVariance() { return variance; }
    public double getStdev() { return stdev; }
    /** Relative standard deviation in percent; empty when the mean is zero. */
    public OptionalDouble getRsdPercent() { return rsdPercent; }
    /** True when population formulas (divisor N) were used. */
    public boolean isPopulation() { return population; }

    @Override
    public String toString() {
        return "Summary{n=" + n + ", mean=" + mean + ", minimum=" + minimum + ", maximum=" + maximum
                + ", range=" + getRange() + ", sumOfSquares=" + sumOfSquares + ", variance=" + variance
                + ", stdev=" + stdev + ", rsdPercent=" + rsdPercent + ", population=" + population + "}";
    }
}
