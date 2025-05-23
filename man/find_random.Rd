% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_random.R
\name{find_random}
\alias{find_random}
\title{Find names of random effects}
\usage{
find_random(x, split_nested = FALSE, flatten = FALSE)
}
\arguments{
\item{x}{A fitted mixed model.}

\item{split_nested}{Logical, if \code{TRUE}, terms from nested random
effects will be returned as separated elements, not as single string
with colon. See 'Examples'.}

\item{flatten}{Logical, if \code{TRUE}, the values are returned as character
vector, not as list. Duplicated values are removed.}
}
\value{
A list of character vectors that represent the name(s) of the
random effects (grouping factors). Depending on the model, the
returned list has following elements:
\itemize{
\item \code{random}, the "random effects" terms from the conditional part of model
\item \code{zero_inflated_random}, the "random effects" terms from the zero-inflation
component of the model. For \strong{brms}, this is named \code{zi_random}.
\item \code{dispersion_random}, the "random effects" terms from the dispersion
component of the model
}

Models of class \code{brmsfit} may also contain elements for auxiliary parameters.
}
\description{
Return the name of the grouping factors from mixed effects models.
}
\examples{
\dontshow{if (require("lme4", quietly = TRUE)) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
data(sleepstudy, package = "lme4")
sleepstudy$mygrp <- sample(1:5, size = 180, replace = TRUE)
sleepstudy$mysubgrp <- NA
for (i in 1:5) {
  filter_group <- sleepstudy$mygrp == i
  sleepstudy$mysubgrp[filter_group] <-
    sample(1:30, size = sum(filter_group), replace = TRUE)
}

m <- lme4::lmer(
  Reaction ~ Days + (1 | mygrp / mysubgrp) + (1 | Subject),
  data = sleepstudy
)

find_random(m)
find_random(m, split_nested = TRUE)
\dontshow{\}) # examplesIf}
}
