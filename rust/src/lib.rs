//! Mean, sum of squared deviations, population and sample variance, standard
//! deviation, coefficient of variation and relative standard deviation for
//! `&[f64]`, with no dependencies.
//!
//! Variance uses a corrected two-pass algorithm with Neumaier compensated
//! summation; the shortcut `Σx² − (Σx)²/n` is never used. Empty input, NaN
//! and ±infinity return an [`Error`] instead of a misleading number.
//!
//! ```
//! let data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
//! assert_eq!(sdtoolkit::population_stdev(&data)?, 2.0);
//! assert_eq!(sdtoolkit::sample_variance(&data)?, 32.0 / 7.0);
//! assert_eq!(sdtoolkit::relative_std_dev(&data, true)?, 40.0);
//! # Ok::<(), sdtoolkit::Error>(())
//! ```
#![forbid(unsafe_code)]
#![warn(missing_docs)]

use std::fmt;

/// Why a statistic could not be computed.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Error {
    /// The input slice is empty.
    Empty,
    /// A sample statistic was requested for fewer than two values.
    TooFew {
        /// Number of values supplied.
        got: usize,
    },
    /// A value is NaN or ±infinity.
    NonFinite {
        /// Position of the offending value.
        index: usize,
        /// The offending value.
        value: f64,
    },
    /// The mean is exactly zero, so CV and RSD are undefined.
    ZeroMean,
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Error::Empty => f.write_str("no data points: at least one value is required"),
            Error::TooFew { got } => {
                write!(
                    f,
                    "sample statistics need at least 2 data points, got {got}"
                )
            }
            Error::NonFinite { index, value } if value.is_nan() => {
                write!(f, "item {index}: NaN is not allowed")
            }
            Error::NonFinite { index, .. } => write!(f, "item {index}: infinity is not allowed"),
            Error::ZeroMean => f.write_str("mean is zero; relative dispersion is undefined"),
        }
    }
}

impl std::error::Error for Error {}

/// Result of [`describe`].
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Summary {
    /// Number of values.
    pub n: usize,
    /// Arithmetic mean.
    pub mean: f64,
    /// Smallest value.
    pub min: f64,
    /// Largest value.
    pub max: f64,
    /// `max - min`.
    pub range: f64,
    /// Σ(x − mean)².
    pub sum_of_squares: f64,
    /// Population or sample variance, depending on `population`.
    pub variance: f64,
    /// Square root of `variance`.
    pub stdev: f64,
    /// `100 × stdev / |mean|`; `None` when the mean is zero.
    pub rsd_percent: Option<f64>,
    /// `true` if the divisor was N, `false` if it was n − 1.
    pub population: bool,
}

/// Neumaier compensated sum.
fn csum(values: impl Iterator<Item = f64>) -> f64 {
    let (mut sum, mut c) = (0.0_f64, 0.0_f64);
    for x in values {
        let t = sum + x;
        c += if sum.abs() >= x.abs() {
            (sum - t) + x
        } else {
            (x - t) + sum
        };
        sum = t;
    }
    sum + c
}

fn validate(data: &[f64]) -> Result<(), Error> {
    if data.is_empty() {
        return Err(Error::Empty);
    }
    match data.iter().position(|x| !x.is_finite()) {
        Some(index) => Err(Error::NonFinite {
            index,
            value: data[index],
        }),
        None => Ok(()),
    }
}

fn need_two(n: usize) -> Result<(), Error> {
    if n < 2 {
        Err(Error::TooFew { got: n })
    } else {
        Ok(())
    }
}

/// Mean and sum of squares of validated data (corrected two-pass).
fn mean_and_ss(data: &[f64]) -> (f64, f64) {
    let n = data.len() as f64;
    let m = csum(data.iter().copied()) / n;
    let sq = csum(data.iter().map(|x| (x - m) * (x - m)));
    let d = csum(data.iter().map(|x| x - m));
    (m, (sq - d * d / n).max(0.0))
}

/// Arithmetic mean.
pub fn mean(data: &[f64]) -> Result<f64, Error> {
    validate(data)?;
    Ok(csum(data.iter().copied()) / data.len() as f64)
}

/// Sum of squared deviations from the mean, `SS = Σ(x − mean)²`.
pub fn sum_of_squares(data: &[f64]) -> Result<f64, Error> {
    validate(data)?;
    Ok(mean_and_ss(data).1)
}

/// Population variance, `SS / N`. A single value gives `0`.
pub fn population_variance(data: &[f64]) -> Result<f64, Error> {
    Ok(sum_of_squares(data)? / data.len() as f64)
}

/// Sample variance with Bessel's correction, `SS / (n − 1)`. Needs n ≥ 2.
///
/// ```
/// let err = sdtoolkit::sample_variance(&[5.0]).unwrap_err();
/// assert_eq!(err, sdtoolkit::Error::TooFew { got: 1 });
/// ```
pub fn sample_variance(data: &[f64]) -> Result<f64, Error> {
    let ss = sum_of_squares(data)?;
    need_two(data.len())?;
    Ok(ss / (data.len() - 1) as f64)
}

/// Population standard deviation, `√(SS / N)`.
pub fn population_stdev(data: &[f64]) -> Result<f64, Error> {
    population_variance(data).map(f64::sqrt)
}

/// Sample standard deviation, `√(SS / (n − 1))`. Needs n ≥ 2.
pub fn sample_stdev(data: &[f64]) -> Result<f64, Error> {
    sample_variance(data).map(f64::sqrt)
}

/// Standard deviation divided by `|mean|`, as a ratio (0.05 means 5 %).
///
/// Uses the sample standard deviation unless `population` is `true`.
/// Returns [`Error::ZeroMean`] when the mean is zero.
pub fn coefficient_of_variation(data: &[f64], population: bool) -> Result<f64, Error> {
    let s = describe(data, population)?;
    if s.mean == 0.0 {
        return Err(Error::ZeroMean);
    }
    Ok(s.stdev / s.mean.abs())
}

/// Relative standard deviation in percent, `100 × SD / |mean|`.
/// See [`coefficient_of_variation`].
pub fn relative_std_dev(data: &[f64], population: bool) -> Result<f64, Error> {
    coefficient_of_variation(data, population).map(|cv| 100.0 * cv)
}

/// All statistics at once. `population = false` divides by n − 1 and needs
/// at least two values; `population = true` divides by N.
///
/// ```
/// let s = sdtoolkit::describe(&[-1.0, 1.0], false)?;
/// assert_eq!(s.rsd_percent, None); // mean is zero
/// # Ok::<(), sdtoolkit::Error>(())
/// ```
pub fn describe(data: &[f64], population: bool) -> Result<Summary, Error> {
    validate(data)?;
    let n = data.len();
    if !population {
        need_two(n)?;
    }
    let (mean, ss) = mean_and_ss(data);
    let variance = ss / if population { n } else { n - 1 } as f64;
    let stdev = variance.sqrt();
    let min = data.iter().copied().fold(f64::INFINITY, f64::min);
    let max = data.iter().copied().fold(f64::NEG_INFINITY, f64::max);
    Ok(Summary {
        n,
        mean,
        min,
        max,
        range: max - min,
        sum_of_squares: ss,
        variance,
        stdev,
        rsd_percent: (mean != 0.0).then(|| 100.0 * (stdev / mean.abs())),
        population,
    })
}
