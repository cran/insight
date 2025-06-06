% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_random_slopes.R
\name{find_random_slopes}
\alias{find_random_slopes}
\title{Find names of random slopes}
\usage{
find_random_slopes(x)
}
\arguments{
\item{x}{A fitted mixed model.}
}
\value{
A list of character vectors with the name(s) of the random slopes, or
\code{NULL} if model has no random slopes. Depending on the model, the returned
list has following elements:
\itemize{
\item \code{random}, the random slopes from the conditional part of model
\item \code{zero_inflated_random}, the random slopes from the zero-inflation component
of the model. For \strong{brms}, this is named \code{zi_random}.
\item \code{dispersion_random}, the random slopes from the dispersion component of the
model
}

Models of class \code{brmsfit} may also contain elements for auxiliary parameters.
}
\description{
Return the name of the random slopes from mixed effects models.
}
\examples{
\dontshow{if (require("lme4", quietly = TRUE)) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
data(sleepstudy, package = "lme4")
m <- lme4::lmer(Reaction ~ Days + (1 + Days | Subject), data = sleepstudy)
find_random_slopes(m)
\dontshow{\}) # examplesIf}
}
