\name{dispersion}
\alias{dispersion}
\alias{sum_of_squares}
\alias{population_variance}
\alias{sample_variance}
\alias{population_stdev}
\alias{sample_stdev}
\alias{coefficient_of_variation}
\alias{relative_std_dev}
\title{Variance, Standard Deviation and Relative Dispersion}
\description{
Population and sample variance and standard deviation, the sum of squared
deviations from the mean, the coefficient of variation and the relative
standard deviation.
}
\usage{
sum_of_squares(x)
population_variance(x)
sample_variance(x)
population_stdev(x)
sample_stdev(x)
coefficient_of_variation(x, population = FALSE)
relative_std_dev(x, population = FALSE)
}
\arguments{
\item{x}{a numeric vector without missing or infinite values.}
\item{population}{if \code{TRUE}, divide by \eqn{N}; otherwise (the default)
use the sample formula, which divides by \eqn{n - 1}.}
}
\details{
With \eqn{SS = \sum (x_i - \bar{x})^2}, the population variance is
\eqn{SS / N} and the sample variance is \eqn{SS / (n - 1)}. Standard
deviations are their square roots. The coefficient of variation is
\eqn{SD / |\bar{x}|} and the relative standard deviation is
\eqn{100 \cdot SD / |\bar{x}|} percent.

\code{sample_variance} and \code{sample_stdev} return the same values as
\code{\link[stats]{var}} and \code{\link[stats]{sd}}, but reject input that
those functions would turn into \code{NA}.

Errors have class \code{"sdcalc_error"}. They are raised for empty input,
fewer than two values with sample formulas, \code{NA}, \code{NaN},
infinite, logical, character or complex values, and a mean of exactly zero
in \code{coefficient_of_variation} and \code{relative_std_dev}. Missing
values are never dropped silently.
}
\value{A single numeric value.}
\seealso{\code{\link{describe}}}
\examples{
x <- c(2, 4, 4, 4, 5, 5, 7, 9)
sum_of_squares(x)         # 32
population_variance(x)    # 4
sample_stdev(x)           # 2.138090
relative_std_dev(x)       # 42.76180
relative_std_dev(x, population = TRUE)  # 40

# Accurate far from zero:
sample_variance(1e9 + c(4, 7, 13, 16))  # 30

try(relative_std_dev(c(-1, 1)))  # mean is zero
}
