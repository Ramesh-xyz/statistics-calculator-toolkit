classic <- c(2, 4, 4, 4, 5, 5, 7, 9)
offset <- 1e9 + c(4, 7, 13, 16)

test_that("classic data set gives the known values", {
  expect_identical(sum_of_squares(classic), 32)
  expect_identical(population_variance(classic), 4)
  expect_identical(population_stdev(classic), 2)
  expect_equal(sample_variance(classic), 32 / 7, tolerance = 1e-15)
  expect_equal(sample_stdev(classic), 2.138089935299395, tolerance = 1e-15)
  expect_equal(relative_std_dev(classic), 42.7617987059879, tolerance = 1e-12)
  expect_identical(relative_std_dev(classic, population = TRUE), 40)
  expect_equal(coefficient_of_variation(classic), 2.138089935299395 / 5, tolerance = 1e-15)
})

test_that("matches stats::var and stats::sd", {
  expect_equal(sample_variance(classic), stats::var(classic), tolerance = 1e-12)
  expect_equal(sample_stdev(classic), stats::sd(classic), tolerance = 1e-12)
})

test_that("data far from zero is exact", {
  expect_identical(sum_of_squares(offset), 90)
  expect_identical(sample_variance(offset), 30)
})

test_that("negative mean uses its absolute value", {
  expect_identical(
    relative_std_dev(c(-2, -4, -6), population = TRUE),
    relative_std_dev(c(2, 4, 6), population = TRUE)
  )
})

test_that("one value", {
  expect_identical(population_variance(7), 0)
  expect_identical(population_stdev(7), 0)
  for (f in list(sample_variance, sample_stdev, relative_std_dev,
                 coefficient_of_variation, describe)) {
    expect_error(f(7), "at least 2", class = "sdcalc_error")
  }
})

test_that("zero mean", {
  expect_error(relative_std_dev(c(-1, 1)), "mean is zero", class = "sdcalc_error")
  expect_error(coefficient_of_variation(c(-2, 0, 2), population = TRUE), "mean is zero")
  expect_identical(describe(c(-1, 1))$rsd_percent, NA_real_)
})

test_that("describe", {
  s <- describe(classic, population = TRUE)
  expect_s3_class(s, "sdcalc_summary")
  expect_identical(
    unclass(s)[c("n", "mean", "minimum", "maximum", "range", "sum_of_squares",
                 "variance", "stdev", "rsd_percent", "population")],
    list(n = 8L, mean = 5, minimum = 2, maximum = 9, range = 7,
         sum_of_squares = 32, variance = 4, stdev = 2, rsd_percent = 40,
         population = TRUE)
  )
  expect_false(describe(c(1, 2))$population)
  expect_output(print(s), "population formulas")
})

test_that("integer input is accepted", {
  expect_identical(population_variance(c(2L, 4L, 4L, 4L, 5L, 5L, 7L, 9L)), 4)
})

test_that("invalid input is rejected", {
  expect_error(sum_of_squares(numeric(0)), "no data points", class = "sdcalc_error")
  expect_error(sum_of_squares(NULL), "no data points")
  expect_error(sum_of_squares(c(1, NA, 3)), "item 2: NA", class = "sdcalc_error")
  expect_error(sum_of_squares(c(1, NaN)), "item 2: NaN")
  expect_error(sum_of_squares(c(1, Inf)), "item 2: infinity")
  expect_error(sum_of_squares(c(1, -Inf)), "infinity")
  expect_error(sum_of_squares(c(TRUE, FALSE)), "logical")
  expect_error(sum_of_squares(NA), "logical")
  expect_error(sum_of_squares(c("1", "2")), "strings")
  expect_error(sum_of_squares(c(1+1i, 2)), "complex")
  expect_error(sum_of_squares(list(1, 2)), "list")
})
