\name{describe}
\alias{describe}
\alias{print.sdcalc_summary}
\title{Summary of Location and Spread}
\description{
Computes the count, mean, minimum, maximum, range, sum of squared
deviations, variance, standard deviation and relative standard deviation in
one pass over validated input.
}
\usage{
describe(x, population = FALSE)

\method{print}{sdcalc_summary}(x, digits = 10, \dots)
}
\arguments{
\item{x}{a numeric vector without missing or infinite values, or an object
of class \code{"sdcalc_summary"} for \code{print}.}
\item{population}{if \code{TRUE}, divide by \eqn{N}; otherwise (the default)
divide by \eqn{n - 1}, which needs at least two values.}
\item{digits}{significant digits to print.}
\item{\dots}{ignored.}
}
\value{
A list of class \code{"sdcalc_summary"} with elements \code{n},
\code{mean}, \code{minimum}, \code{maximum}, \code{range},
\code{sum_of_squares}, \code{variance}, \code{stdev}, \code{rsd_percent}
and \code{population}. \code{rsd_percent} is \code{NA} when the mean is
zero.
}
\seealso{\code{\link{sample_stdev}}}
\examples{
s <- describe(c(2, 4, 4, 4, 5, 5, 7, 9), population = TRUE)
s
s$stdev        # 2
s$rsd_percent  # 40

describe(c(-1, 1))$rsd_percent  # NA
}
