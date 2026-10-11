sdcalc_stop <- function(message) {
  stop(structure(
    class = c("sdcalc_error", "error", "condition"),
    list(message = message, call = NULL)
  ))
}

# Validate input and return a plain double vector.
as_values <- function(x) {
  if (is.list(x)) {
    sdcalc_stop("expected a numeric vector, got a list")
  }
  if (is.logical(x) && length(x) > 0L) {
    sdcalc_stop("logical values are not numbers")
  }
  if (is.character(x)) {
    sdcalc_stop("strings are not accepted; convert with as.numeric() first")
  }
  if (is.complex(x)) {
    sdcalc_stop("complex numbers are not real numbers")
  }
  if (is.null(x) || length(x) == 0L) {
    sdcalc_stop("no data points: at least one value is required")
  }
  if (!is.numeric(x)) {
    sdcalc_stop(sprintf("expected a numeric vector, got %s", class(x)[1L]))
  }
  x <- as.double(x)
  bad <- which(is.na(x) | is.infinite(x))
  if (length(bad) > 0L) {
    i <- bad[1L]
    what <- if (is.nan(x[i])) "NaN" else if (is.na(x[i])) "NA (missing value)" else "infinity"
    sdcalc_stop(sprintf("item %d: %s is not allowed", i, what))
  }
  x
}

need_two <- function(n) {
  if (n < 2L) {
    sdcalc_stop(sprintf("sample statistics need at least 2 data points, got %d", n))
  }
}

# Corrected two-pass algorithm. base::mean() and base::sum() accumulate in
# long double, and mean() already refines its result with a second pass.
mean_and_ss <- function(x) {
  n <- length(x)
  m <- mean(x)
  d <- x - m
  ss <- sum(d * d) - sum(d)^2 / n
  list(mean = m, ss = max(ss, 0))
}

sum_of_squares <- function(x) {
  mean_and_ss(as_values(x))$ss
}

population_variance <- function(x) {
  x <- as_values(x)
  mean_and_ss(x)$ss / length(x)
}

sample_variance <- function(x) {
  x <- as_values(x)
  need_two(length(x))
  mean_and_ss(x)$ss / (length(x) - 1)
}

population_stdev <- function(x) {
  sqrt(population_variance(x))
}

sample_stdev <- function(x) {
  sqrt(sample_variance(x))
}

coefficient_of_variation <- function(x, population = FALSE) {
  x <- as_values(x)
  n <- length(x)
  if (!isTRUE(population)) need_two(n)
  r <- mean_and_ss(x)
  if (r$mean == 0) {
    sdcalc_stop("mean is zero; relative dispersion is undefined")
  }
  sqrt(r$ss / (if (isTRUE(population)) n else n - 1)) / abs(r$mean)
}

relative_std_dev <- function(x, population = FALSE) {
  100 * coefficient_of_variation(x, population = population)
}

describe <- function(x, population = FALSE) {
  x <- as_values(x)
  n <- length(x)
  population <- isTRUE(population)
  if (!population) need_two(n)
  r <- mean_and_ss(x)
  var <- r$ss / (if (population) n else n - 1)
  sd <- sqrt(var)
  structure(
    list(
      n = n,
      mean = r$mean,
      minimum = min(x),
      maximum = max(x),
      range = max(x) - min(x),
      sum_of_squares = r$ss,
      variance = var,
      stdev = sd,
      rsd_percent = if (r$mean == 0) NA_real_ else 100 * sd / abs(r$mean),
      population = population
    ),
    class = "sdcalc_summary"
  )
}

print.sdcalc_summary <- function(x, digits = 10, ...) {
  kind <- if (x$population) "population" else "sample"
  rows <- c(
    n = format(x$n),
    mean = format(x$mean, digits = digits),
    min = format(x$minimum, digits = digits),
    max = format(x$maximum, digits = digits),
    range = format(x$range, digits = digits),
    "sum of squares" = format(x$sum_of_squares, digits = digits),
    variance = format(x$variance, digits = digits),
    "std dev" = format(x$stdev, digits = digits),
    "RSD (%)" = format(x$rsd_percent, digits = digits)
  )
  cat(sprintf("%-15s %s", names(rows), rows), sep = "\n")
  cat(sprintf("(%s formulas, divisor: %s)\n", kind, if (x$population) "N" else "n - 1"))
  invisible(x)
}
