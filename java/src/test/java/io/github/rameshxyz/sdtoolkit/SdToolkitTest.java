package io.github.rameshxyz.sdtoolkit;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.function.Executable;

class SdToolkitTest {
    static final double[] CLASSIC = {2, 4, 4, 4, 5, 5, 7, 9};
    static final double[] LARGE_OFFSET = {1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16};

    static void assertError(String fragment, Executable call) {
        StatisticsException e = assertThrows(StatisticsException.class, call);
        assertTrue(e.getMessage().contains(fragment), e.getMessage());
    }

    @Test
    void classicValues() {
        assertEquals(5.0, SdToolkit.mean(CLASSIC));
        assertEquals(32.0, SdToolkit.sumOfSquares(CLASSIC));
        assertEquals(4.0, SdToolkit.populationVariance(CLASSIC));
        assertEquals(2.0, SdToolkit.populationStdev(CLASSIC));
        assertEquals(32.0 / 7, SdToolkit.sampleVariance(CLASSIC), 1e-15);
        assertEquals(2.138089935299395, SdToolkit.sampleStdev(CLASSIC), 1e-15);
        assertEquals(42.7617987059879, SdToolkit.relativeStdDev(CLASSIC), 1e-12);
        assertEquals(40.0, SdToolkit.relativeStdDev(CLASSIC, true), 1e-12);
        assertEquals(0.4, SdToolkit.coefficientOfVariation(CLASSIC, true), 1e-15);
    }

    @Test
    void largeOffsetIsExact() {
        assertEquals(90.0, SdToolkit.sumOfSquares(LARGE_OFFSET));
        assertEquals(30.0, SdToolkit.sampleVariance(LARGE_OFFSET));
    }

    @Test
    void negativeMeanUsesAbsoluteValue() {
        assertEquals(SdToolkit.relativeStdDev(new double[] {2, 4, 6}, true),
                SdToolkit.relativeStdDev(new double[] {-2, -4, -6}, true));
    }

    @Test
    void singleValue() {
        assertEquals(0.0, SdToolkit.populationVariance(7));
        assertEquals(0.0, SdToolkit.populationStdev(7));
        assertError("at least 2", () -> SdToolkit.sampleVariance(7));
        assertError("at least 2", () -> SdToolkit.sampleStdev(7));
        assertError("at least 2", () -> SdToolkit.relativeStdDev(7));
        assertError("at least 2", () -> SdToolkit.describe(7));
    }

    @Test
    void emptyAndNull() {
        assertError("no data points", () -> SdToolkit.mean());
        assertError("no data points", () -> SdToolkit.populationVariance(new double[0]));
        assertError("no data points", () -> SdToolkit.mean((double[]) null));
    }

    @Test
    void nonFinite() {
        assertError("item 1: NaN", () -> SdToolkit.mean(1, Double.NaN));
        assertError("item 1: infinity", () -> SdToolkit.mean(1, Double.POSITIVE_INFINITY));
        assertError("infinity", () -> SdToolkit.sampleStdev(Double.NEGATIVE_INFINITY, 1));
    }

    @Test
    void zeroMean() {
        assertError("mean is zero", () -> SdToolkit.relativeStdDev(-1, 1));
        assertError("mean is zero", () -> SdToolkit.coefficientOfVariation(new double[] {-2, 0, 2}, true));
        assertFalse(SdToolkit.describe(-1, 1).getRsdPercent().isPresent());
    }

    @Test
    void describe() {
        Summary s = SdToolkit.describe(CLASSIC, true);
        assertEquals(8, s.getN());
        assertEquals(5.0, s.getMean());
        assertEquals(2.0, s.getMinimum());
        assertEquals(9.0, s.getMaximum());
        assertEquals(7.0, s.getRange());
        assertEquals(32.0, s.getSumOfSquares());
        assertEquals(4.0, s.getVariance());
        assertEquals(2.0, s.getStdev());
        assertEquals(40.0, s.getRsdPercent().getAsDouble(), 1e-12);
        assertTrue(s.isPopulation());
        assertFalse(SdToolkit.describe(1, 2).isPopulation());
    }

    @Test
    void constantData() {
        assertEquals(0.0, SdToolkit.sampleVariance(3.3, 3.3, 3.3, 3.3, 3.3));
        assertEquals(0.0, SdToolkit.relativeStdDev(3.3, 3.3, 3.3, 3.3, 3.3));
    }
}
