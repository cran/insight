% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/validate_argument.R
\name{validate_argument}
\alias{validate_argument}
\title{Validate arguments against a given set of options}
\usage{
validate_argument(argument, options)
}
\arguments{
\item{argument}{The bare name of the argument to be validated.}

\item{options}{Valid options, usually a character vector.}
}
\value{
\code{argument} if it is a valid option, else an error is thrown.
}
\description{
This is a replacement for \code{match.arg()}, however, the error
string should be more informative for users. The name of the affected argument
is shown, and possible typos as well as remaining valid options. Note that
the argument \code{several.ok} is always \code{FALSE} in \code{validate_argument()}, i.e.
this function - unlike \code{match.arg()} - does \emph{not} allow evaluating several
valid options at once.
}
\examples{
foo <- function(test = "small") {
  validate_argument(test, c("small", "medium", "large"))
}
foo("small")
# errors:
# foo("masll")
}
