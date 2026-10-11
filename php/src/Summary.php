<?php

declare(strict_types=1);

namespace RameshXyz\SdToolkit;

/** Result of Dispersion::describe(). $rsdPercent is null when the mean is zero. */
final class Summary
{
    public function __construct(
        public readonly int $n,
        public readonly float $mean,
        public readonly float $minimum,
        public readonly float $maximum,
        public readonly float $range,
        public readonly float $sumOfSquares,
        public readonly float $variance,
        public readonly float $stdev,
        public readonly ?float $rsdPercent,
        public readonly bool $population,
    ) {
    }
}
