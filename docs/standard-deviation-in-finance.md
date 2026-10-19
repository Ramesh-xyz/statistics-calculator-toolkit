---
layout: article
title: Standard deviation in finance
description: Volatility, the Sharpe ratio, beta and value at risk, each worked from the same ten daily returns with the sample standard deviation.
kicker: Guide · Risk measures
lede: "Most risk numbers quoted for a stock or a fund are the standard deviation of its returns, rescaled or divided by something. Volatility, the Sharpe ratio, beta and a simple value at risk all start from the same two quantities that sdtoolkit computes: the mean and the sample standard deviation."
returns: [[1.2, 0.8], [-0.8, -0.5], [0.5, 0.3], [2.1, 1.2], [-1.5, -1.1], [0.9, 0.6], [-0.3, -0.2], [1.4, 0.9], [-0.6, -0.4], [0.7, 0.4]]
stats:
  - label: Annual volatility
    value: "17.9 %"
    note: daily SD × √252
  - label: Sharpe ratio
    value: "4.79"
    note: annualised
  - label: Beta
    value: "1.54"
    note: vs the index
  - label: 95 % one-day VaR
    value: "−1.49 %"
    note: mean − 1.645 SD
---

## The data

Ten daily returns, in percent, for a stock and for the market index it
trades against (illustrative numbers):

| day | stock | market |
|---|---|---|
| 1 | 1.2 | 0.8 |
| 2 | −0.8 | −0.5 |
| 3 | 0.5 | 0.3 |
| 4 | 2.1 | 1.2 |
| 5 | −1.5 | −1.1 |
| 6 | 0.9 | 0.6 |
| 7 | −0.3 | −0.2 |
| 8 | 1.4 | 0.9 |
| 9 | −0.6 | −0.4 |
| 10 | 0.7 | 0.4 |

```python
>>> import sdtoolkit as sd
>>> stock = [1.2, -0.8, 0.5, 2.1, -1.5, 0.9, -0.3, 1.4, -0.6, 0.7]
>>> market = [0.8, -0.5, 0.3, 1.2, -1.1, 0.6, -0.2, 0.9, -0.4, 0.4]
>>> sd.mean(stock)
0.36
>>> round(sd.sample_variance(stock), 6)
1.267111
>>> round(sd.sample_stdev(stock), 4)
1.1257
```

Returns are a sample of what the stock could do, not the whole population,
so the n − 1 versions are the right ones (see
[sample-vs-population.md](sample-vs-population.md)). If you want to see where
the n − 1 comes from, the
[variance formula](https://standarddeviationcalculator.net/variance-formula/)
page derives both versions side by side.

## Volatility

Volatility is the standard deviation of returns, quoted on a yearly scale.
Daily returns are close enough to independent that their variances add, so
the yearly variance is about 252 times the daily one (252 trading days), and
the yearly standard deviation is √252 times the daily one:

```
annual volatility = daily SD × √252
                  = 1.1257 % × 15.875
                  ≈ 17.9 %
```

```python
>>> import math
>>> round(sd.sample_stdev(stock) * math.sqrt(252), 2)
17.87
```

Use √52 for weekly returns and √12 for monthly ones. Ten days is far too
short for a real estimate; a year of daily data is the usual minimum. A
[volatility calculator](https://standarddeviationcalculator.net/volatility-calculator/)
does the annualising from a column of prices, including the step from
prices to returns.

## Sharpe ratio

The Sharpe ratio asks how much return you got per unit of standard
deviation, after subtracting what a risk-free asset would have paid:

```
Sharpe = mean(return − risk-free) / SD(return − risk-free)
```

With a risk-free rate of 0.02 % a day:

```python
>>> excess = [r - 0.02 for r in stock]
>>> daily = sd.mean(excess) / sd.sample_stdev(excess)
>>> round(daily, 4)
0.302
>>> round(daily * math.sqrt(252), 2)
4.79
```

The mean scales by 252 and the SD by √252, so the ratio scales by √252. An
annual Sharpe of 4.8 would be extraordinary; it comes from ten good days, not
from a good strategy, which is why the sample length matters as much as the
number. To compare funds over the same period, a
[Sharpe ratio calculator](https://standarddeviationcalculator.net/sharpe-ratio-calculator/)
takes the returns and the risk-free rate directly.

## Beta

Beta measures how much the stock moves when the market moves. It is the
covariance of the two return series divided by the variance of the market:

```
β = Cov(stock, market) / Var(market)
```

sdtoolkit has no covariance function, but the formula is one line on top of
the means:

```python
>>> ms, mm = sd.mean(stock), sd.mean(market)
>>> cov = sum((a - ms) * (b - mm) for a, b in zip(stock, market)) / (len(stock) - 1)
>>> round(cov, 6)
0.815556
>>> round(sd.sample_variance(market), 6)
0.528889
>>> round(cov / sd.sample_variance(market), 3)
1.542
```

Both terms use n − 1, so the choice cancels; what matters is using the same
divisor in both. A beta of 1.54 means the stock has moved about 1.5 % for
each 1 % move in the index. A
[covariance calculator](https://standarddeviationcalculator.net/covariance-calculator/)
shows the cross-products step by step, and a
[stock beta calculator](https://standarddeviationcalculator.net/stock-beta-calculator/)
goes straight from the two price series to β.

## A one-day value at risk

If daily returns were normal, the worst day in twenty would sit about 1.645
standard deviations below the mean:

```
VaR(95 %) = mean − 1.645 × SD
          = 0.36 − 1.645 × 1.1257
          ≈ −1.49 %
```

The 1.645 comes from the normal distribution; a
[z-table](https://standarddeviationcalculator.net/z-table/) lists the value
for any other confidence level (2.326 for 99 %). Real returns have fatter
tails than the normal curve, so this figure understates how bad the bad days
get; treat it as a floor on the risk, not a ceiling.

## Summary

| measure | built from | value here |
|---|---|---|
| daily SD | sample SD of returns | 1.13 % |
| annual volatility | daily SD × √252 | 17.9 % |
| Sharpe ratio (annual) | mean excess ÷ SD, × √252 | 4.79 |
| beta | covariance ÷ market variance | 1.54 |
| 95 % one-day VaR | mean − 1.645 × SD | −1.49 % |

For more of these tools in one place, the
[finance calculators](https://standarddeviationcalculator.net/finance/)
index groups them by topic.
