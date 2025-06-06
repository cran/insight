% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/null_model.R
\name{null_model}
\alias{null_model}
\alias{null_model.default}
\title{Compute intercept-only model for regression models}
\usage{
null_model(model, ...)

\method{null_model}{default}(model, verbose = TRUE, ...)
}
\arguments{
\item{model}{A (mixed effects) model.}

\item{...}{Arguments passed to or from other methods.}

\item{verbose}{Toggle off warnings.}
}
\value{
The null-model of \code{x}
}
\description{
This function computes the null-model (i.e. \code{(y ~ 1)}) of
a model. For mixed models, the null-model takes random effects into account.
}
\examples{
\dontshow{if (require("lme4", quietly = TRUE)) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
data(sleepstudy)
m <- lmer(Reaction ~ Days + (1 + Days | Subject), data = sleepstudy)
summary(m)
summary(null_model(m))
\dontshow{\}) # examplesIf}
}
