% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_parameter_zi.R
\name{find_parameters.zeroinfl}
\alias{find_parameters.zeroinfl}
\alias{find_parameters.mhurdle}
\title{Find names of model parameters from zero-inflated models}
\usage{
\method{find_parameters}{zeroinfl}(
  x,
  component = c("all", "conditional", "zi", "zero_inflated"),
  flatten = FALSE,
  ...
)

\method{find_parameters}{mhurdle}(
  x,
  component = c("all", "conditional", "zi", "zero_inflated", "infrequent_purchase", "ip",
    "auxiliary"),
  flatten = FALSE,
  ...
)
}
\arguments{
\item{x}{A fitted model.}

\item{component}{Should all predictor variables, predictor variables for the
conditional model, the zero-inflated part of the model, the dispersion
term or the instrumental variables be returned? Applies to models
with zero-inflated and/or dispersion formula, or to models with instrumental
variable (so called fixed-effects regressions). May be abbreviated. Note that the
\emph{conditional} component is also called \emph{count} or \emph{mean}
component, depending on the model.}

\item{flatten}{Logical, if \code{TRUE}, the values are returned
as character vector, not as list. Duplicated values are removed.}

\item{...}{Currently not used.}
}
\value{
A list of parameter names. The returned list may have following
elements:
\itemize{
\item \code{conditional}, the "fixed effects" part from the model.
\item \code{zero_inflated}, the "fixed effects" part from the zero-inflation
component of the model.
}
}
\description{
Returns the names of model parameters, like they typically
appear in the \code{summary()} output.
}
\examples{
data(mtcars)
m <- lm(mpg ~ wt + cyl + vs, data = mtcars)
find_parameters(m)
}
