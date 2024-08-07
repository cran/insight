% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_parameters_others.R
\name{get_parameters.betareg}
\alias{get_parameters.betareg}
\alias{get_parameters.glmgee}
\alias{get_parameters.DirichletRegModel}
\alias{get_parameters.averaging}
\alias{get_parameters.glmx}
\alias{get_parameters.clm2}
\alias{get_parameters.mvord}
\alias{get_parameters.mjoint}
\title{Get model parameters from models with special components}
\usage{
\method{get_parameters}{betareg}(
  x,
  component = c("all", "conditional", "precision", "location", "distributional",
    "auxiliary"),
  ...
)

\method{get_parameters}{glmgee}(x, component = c("all", "conditional", "dispersion"), ...)

\method{get_parameters}{DirichletRegModel}(
  x,
  component = c("all", "conditional", "precision", "location", "distributional",
    "auxiliary"),
  ...
)

\method{get_parameters}{averaging}(x, component = c("conditional", "full"), ...)

\method{get_parameters}{glmx}(
  x,
  component = c("all", "conditional", "extra", "location", "distributional", "auxiliary"),
  ...
)

\method{get_parameters}{clm2}(x, component = c("all", "conditional", "scale"), ...)

\method{get_parameters}{mvord}(
  x,
  component = c("all", "conditional", "thresholds", "correlation"),
  ...
)

\method{get_parameters}{mjoint}(x, component = c("all", "conditional", "survival"), ...)
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

\item{...}{Currently not used.}
}
\value{
A data frame with three columns: the parameter names, the related
point estimates and the component.
}
\description{
Returns the coefficients from a model.
}
\examples{
data(mtcars)
m <- lm(mpg ~ wt + cyl + vs, data = mtcars)
get_parameters(m)
}
