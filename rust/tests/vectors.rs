use sdtoolkit::*;

const CLASSIC: [f64; 8] = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];

fn close(a: f64, b: f64) -> bool {
    (a - b).abs() <= 1e-12 * a.abs().max(b.abs())
}

#[test]
fn classic() {
    assert_eq!(mean(&CLASSIC), Ok(5.0));
    assert_eq!(sum_of_squares(&CLASSIC), Ok(32.0));
    assert_eq!(population_variance(&CLASSIC), Ok(4.0));
    assert_eq!(population_stdev(&CLASSIC), Ok(2.0));
    assert!(close(sample_variance(&CLASSIC).unwrap(), 32.0 / 7.0));
    assert!(close(sample_stdev(&CLASSIC).unwrap(), 2.138089935299395));
    assert!(close(
        relative_std_dev(&CLASSIC, false).unwrap(),
        42.7617987059879
    ));
    assert_eq!(relative_std_dev(&CLASSIC, true), Ok(40.0));
    assert_eq!(coefficient_of_variation(&CLASSIC, true), Ok(0.4));
}

#[test]
fn large_offset_exact() {
    let data = [1e9 + 4.0, 1e9 + 7.0, 1e9 + 13.0, 1e9 + 16.0];
    assert_eq!(sum_of_squares(&data), Ok(90.0));
    assert_eq!(sample_variance(&data), Ok(30.0));
}

#[test]
fn negative_mean_uses_abs() {
    let a = relative_std_dev(&[-2.0, -4.0, -6.0], true).unwrap();
    assert!(a > 0.0);
    assert_eq!(Ok(a), relative_std_dev(&[2.0, 4.0, 6.0], true));
}

#[test]
fn single_value() {
    assert_eq!(population_variance(&[7.0]), Ok(0.0));
    assert_eq!(sample_variance(&[7.0]), Err(Error::TooFew { got: 1 }));
    assert_eq!(sample_stdev(&[7.0]), Err(Error::TooFew { got: 1 }));
    assert_eq!(describe(&[7.0], false), Err(Error::TooFew { got: 1 }));
    assert!(Error::TooFew { got: 1 }.to_string().contains("at least 2"));
}

#[test]
fn empty() {
    assert_eq!(mean(&[]), Err(Error::Empty));
    assert!(Error::Empty.to_string().contains("no data points"));
}

#[test]
fn non_finite() {
    let e = mean(&[1.0, f64::NAN]).unwrap_err();
    assert!(matches!(e, Error::NonFinite { index: 1, .. }));
    assert_eq!(e.to_string(), "item 1: NaN is not allowed");
    let e = population_variance(&[f64::NEG_INFINITY]).unwrap_err();
    assert_eq!(
        e,
        Error::NonFinite {
            index: 0,
            value: f64::NEG_INFINITY
        }
    );
    assert_eq!(e.to_string(), "item 0: infinity is not allowed");
}

#[test]
fn zero_mean() {
    let e = relative_std_dev(&[-1.0, 1.0], false).unwrap_err();
    assert_eq!(e, Error::ZeroMean);
    assert!(e.to_string().contains("mean is zero"));
    assert_eq!(describe(&[-1.0, 1.0], false).unwrap().rsd_percent, None);
}

#[test]
fn describe_population() {
    let s = describe(&CLASSIC, true).unwrap();
    assert_eq!(
        s,
        Summary {
            n: 8,
            mean: 5.0,
            min: 2.0,
            max: 9.0,
            range: 7.0,
            sum_of_squares: 32.0,
            variance: 4.0,
            stdev: 2.0,
            rsd_percent: Some(40.0),
            population: true,
        }
    );
}
