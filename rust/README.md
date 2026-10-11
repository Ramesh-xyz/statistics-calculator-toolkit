# sdtoolkit for Rust

Mean, sum of squared deviations, population and sample variance, standard
deviation, coefficient of variation and relative standard deviation (RSD) for
`&[f64]`. No dependencies, no `unsafe`.

API reference: <https://docs.rs/sdtoolkit>

## Install

```
cargo add sdtoolkit
```

## Usage

```rust
use sdtoolkit::{describe, relative_std_dev, sample_stdev, sample_variance, Error};

fn main() -> Result<(), Error> {
    let data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];

    println!("{}", sample_stdev(&data)?);            // 2.138089935299395
    println!("{}", relative_std_dev(&data, false)?); // 42.7617987059879

    let s = describe(&data, true)?;
    println!("{} {} {} {:?}", s.mean, s.variance, s.stdev, s.rsd_percent); // 5 4 2 Some(40.0)

    assert_eq!(sample_variance(&[5.0]), Err(Error::TooFew { got: 1 }));
    Ok(())
}
```

## Functions

Every function returns `Result<_, sdtoolkit::Error>`.

| function | returns |
|---|---|
| `mean(data)` | arithmetic mean |
| `sum_of_squares(data)` | SS = Σ(x − x̄)² |
| `population_variance(data)` | SS / N |
| `sample_variance(data)` | SS / (n − 1) |
| `population_stdev(data)` | √(SS / N) |
| `sample_stdev(data)` | √(SS / (n − 1)) |
| `coefficient_of_variation(data, population)` | SD / \|x̄\|, as a ratio |
| `relative_std_dev(data, population)` | 100 × SD / \|x̄\|, in percent |
| `describe(data, population)` | `Summary` with all of the above plus min, max, range |

`population == false` uses the sample formulas (divide by n − 1). The
formulas are derived on the
[standard deviation formula reference](https://standarddeviationcalculator.net/standard-deviation-formula/).

## Errors and edge cases

| input | result |
|---|---|
| empty slice | `Error::Empty` |
| one value, sample statistic | `Error::TooFew { got: 1 }` (population variance of one value is `0.0`) |
| NaN or ±infinity | `Error::NonFinite { index, value }` |
| mean exactly 0, CV or RSD | `Error::ZeroMean`; `describe` sets `rsd_percent` to `None` |

A negative mean is fine: CV and RSD divide by |mean|. `Error` implements
`std::error::Error`, so it works with `?` and `Box<dyn Error>`.

## Precision

Variance uses a corrected two-pass algorithm with Neumaier compensated
summation, never the shortcut Σx² − (Σx)²/n. For data such as
`1e9 + {4, 7, 13, 16}` the sample variance is exactly `30.0`. Results match
the Python `sdtoolkit` package to about 1e-12 relative tolerance; they are not
guaranteed to be bit-identical, because Python's `math.fsum` is exactly
rounded and Neumaier summation is not.

Minimum supported Rust version: 1.60.

## License

MIT. Source: <https://github.com/Ramesh-xyz/statistics-calculator-toolkit>
