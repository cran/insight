% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_response.R
\name{get_response}
\alias{get_response}
\alias{get_response.default}
\alias{get_response.nestedLogit}
\title{Get the values from the response variable}
\usage{
get_response(x, ...)

\method{get_response}{default}(
  x,
  select = NULL,
  as_proportion = TRUE,
  source = "environment",
  verbose = TRUE,
  ...
)

\method{get_response}{nestedLogit}(x, dichotomies = FALSE, source = "environment", ...)
}
\arguments{
\item{x}{A fitted model.}

\item{...}{Currently not used.}

\item{select}{Optional name(s) of response variables for which to extract values.
Can be used in case of regression models with multiple response variables.}

\item{as_proportion}{Logical, if \code{TRUE} and the response value is a proportion
(e.g. \code{y1 / y2}), then the returned response value will be a vector with
the result of this proportion. Else, always a data frame is returned.}

\item{source}{String, indicating from where data should be recovered. If
\code{source = "environment"} (default), data is recovered from the environment
(e.g. if the data is in the workspace). This option is usually the fastest
way of getting data and ensures that the original variables used for model
fitting are returned. Note that always the \emph{current} data is recovered from
the environment. Hence, if the data was modified \emph{after} model fitting
(e.g., variables were recoded or rows filtered), the returned data may no
longer equal the model data. If \code{source = "frame"} (or \code{"mf"}), the data
is taken from the model frame. Any transformed variables are back-transformed,
if possible. This option returns the data even if it is not available in
the environment, however, in certain edge cases back-transforming to the
original data may fail. If \code{source = "environment"} fails to recover the
data, it tries to extract the data from the model frame; if
\code{source = "frame"} and data cannot be extracted from the model frame, data
will be recovered from the environment. Both ways only returns observations
that have no missing data in the variables used for model fitting.}

\item{verbose}{Toggle warnings.}

\item{dichotomies}{Logical, if model is a \code{nestedLogit} objects, returns
the response values for the dichotomies.}
}
\value{
The values of the response variable, as vector, or a data frame if
\code{x} has more than one defined response variable.
}
\description{
Returns the values the response variable(s) from a model object.
If the model is a multivariate response model, a data frame with values
from all response variables is returned.
}
\examples{
\dontshow{if (require("lme4", quietly = TRUE)) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
data(cbpp)
cbpp$trials <- cbpp$size - cbpp$incidence
dat <<- cbpp

m <- glm(cbind(incidence, trials) ~ period, data = dat, family = binomial)
head(get_response(m))
get_response(m, select = "incidence")

data(mtcars)
m <- lm(mpg ~ wt + cyl + vs, data = mtcars)
get_response(m)
\dontshow{\}) # examplesIf}
}
