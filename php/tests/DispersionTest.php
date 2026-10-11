<?php

declare(strict_types=1);

namespace RameshXyz\SdToolkit\Tests;

use PHPUnit\Framework\TestCase;
use RameshXyz\SdToolkit\Dispersion as D;
use RameshXyz\SdToolkit\StatisticsException;

final class DispersionTest extends TestCase
{
    private const CLASSIC = [2, 4, 4, 4, 5, 5, 7, 9];
    private const OFFSET = [1e9 + 4, 1e9 + 7, 1e9 + 13, 1e9 + 16];

    public function testClassic(): void
    {
        self::assertSame(5.0, D::mean(self::CLASSIC));
        self::assertSame(32.0, D::sumOfSquares(self::CLASSIC));
        self::assertSame(4.0, D::populationVariance(self::CLASSIC));
        self::assertSame(2.0, D::populationStdev(self::CLASSIC));
        self::assertEqualsWithDelta(32 / 7, D::sampleVariance(self::CLASSIC), 1e-15);
        self::assertEqualsWithDelta(2.138089935299395, D::sampleStdev(self::CLASSIC), 1e-15);
        self::assertEqualsWithDelta(42.7617987059879, D::relativeStdDev(self::CLASSIC), 1e-12);
        self::assertSame(40.0, D::relativeStdDev(self::CLASSIC, true));
        self::assertEqualsWithDelta(2.138089935299395 / 5, D::coefficientOfVariation(self::CLASSIC), 1e-15);
    }

    public function testLargeOffsetIsExact(): void
    {
        self::assertSame(90.0, D::sumOfSquares(self::OFFSET));
        self::assertSame(30.0, D::sampleVariance(self::OFFSET));
    }

    public function testNegativeMeanUsesAbsoluteValue(): void
    {
        self::assertSame(D::relativeStdDev([2, 4, 6], true), D::relativeStdDev([-2, -4, -6], true));
    }

    public function testSingleValue(): void
    {
        self::assertSame(0.0, D::populationVariance([7]));
        self::assertSame(0.0, D::populationStdev([7]));
        foreach (['sampleVariance', 'sampleStdev', 'relativeStdDev', 'coefficientOfVariation', 'describe'] as $fn) {
            $this->assertThrowsMessage('at least 2', fn () => D::$fn([7]));
        }
    }

    public function testZeroMean(): void
    {
        $this->assertThrowsMessage('mean is zero', fn () => D::relativeStdDev([-1, 1]));
        $this->assertThrowsMessage('mean is zero', fn () => D::coefficientOfVariation([-2, 0, 2], true));
        self::assertNull(D::describe([-1, 1])->rsdPercent);
    }

    public function testDescribe(): void
    {
        $s = D::describe(self::CLASSIC, true);
        self::assertSame(
            [8, 5.0, 2.0, 9.0, 7.0, 32.0, 4.0, 2.0, 40.0, true],
            [$s->n, $s->mean, $s->minimum, $s->maximum, $s->range, $s->sumOfSquares, $s->variance, $s->stdev, $s->rsdPercent, $s->population],
        );
        self::assertFalse(D::describe([1, 2])->population);
    }

    public function testIterableInput(): void
    {
        $gen = (function () {
            yield 1;
            yield 2.0;
            yield 3;
        })();
        self::assertSame(2.0, D::mean($gen));
    }

    public function testExceptionType(): void
    {
        self::assertTrue(is_subclass_of(StatisticsException::class, \InvalidArgumentException::class));
    }

    public function testEmpty(): void
    {
        foreach (['mean', 'sumOfSquares', 'populationVariance', 'populationStdev'] as $fn) {
            $this->assertThrowsMessage('no data points', fn () => D::$fn([]));
        }
    }

    public function testRejectedItems(): void
    {
        $cases = [
            'item 1: NaN' => [1, NAN],
            'item 1: infinity' => [1, INF],
            'infinity' => [1, -INF],
            'item 1: null' => [1, null, 3],
            'booleans' => [1, true],
            'strings are not accepted' => [1, '2'],
            'not a real number' => [1, [2]],
        ];
        foreach ($cases as $message => $data) {
            $this->assertThrowsMessage($message, fn () => D::mean($data));
        }
    }

    private function assertThrowsMessage(string $needle, callable $fn): void
    {
        try {
            $fn();
        } catch (StatisticsException $e) {
            self::assertStringContainsString($needle, $e->getMessage());
            return;
        }
        self::fail("expected StatisticsException containing '$needle'");
    }
}
