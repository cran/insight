% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/standardize_names.R
\name{standardize_names}
\alias{standardize_names}
\alias{standardize_names.parameters_model}
\title{Standardize column names}
\usage{
standardize_names(data, ...)

\method{standardize_names}{parameters_model}(
  data,
  style = c("easystats", "broom"),
  ignore_estimate = FALSE,
  ...
)
}
\arguments{
\item{data}{A data frame. In particular, objects from \emph{easystats}
package functions like \code{\link[parameters:model_parameters]{parameters::model_parameters()}} or
\code{\link[effectsize:effectsize]{effectsize::effectsize()}} are accepted, but also data frames returned by
\code{broom::tidy()} are valid objects.}

\item{...}{Currently not used.}

\item{style}{Standardization can either be based on the naming conventions
from the \href{https://easystats.github.io/easystats/}{easystats-project}, or on
\strong{broom}'s naming scheme.}

\item{ignore_estimate}{Logical, if \code{TRUE}, column names like \code{"mean"} or
\code{"median"} will \emph{not} be converted to \code{"Coefficient"} resp. \code{"estimate"}.}
}
\value{
A data frame, with standardized column names.
}
\description{
Standardize column names from data frames, in particular objects returned
from \code{\link[parameters:model_parameters]{parameters::model_parameters()}}, so column names are consistent and
the same for any model object.
}
\details{
This method is in particular useful for package developers or users
who use, e.g., \code{\link[parameters:model_parameters]{parameters::model_parameters()}} in their own code or
functions to retrieve model parameters for further processing. As
\code{model_parameters()} returns a data frame with varying column names
(depending on the input), accessing the required information is probably
not quite straightforward. In such cases, \code{standardize_names()} can be
used to get consistent, i.e. always the same column names, no matter what
kind of model was used in \code{model_parameters()}.

For \code{style = "broom"}, column names are renamed to match \strong{broom}'s
naming scheme, i.e. \code{Parameter} is renamed to \code{term}, \code{Coefficient} becomes
\code{estimate} and so on.

For \code{style = "easystats"}, when \code{data} is an object from \code{broom::tidy()},
column names are converted from "broom"-style into "easystats"-style.
}
\examples{
\dontshow{if (require("parameters")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
model <- lm(mpg ~ wt + cyl, data = mtcars)
mp <- model_parameters(model)

as.data.frame(mp)
standardize_names(mp)
standardize_names(mp, style = "broom")
\dontshow{\}) # examplesIf}
}
