% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/all_equal_models.R
\name{all_models_equal}
\alias{all_models_equal}
\alias{all_models_same_class}
\title{Checks if all objects are models of same class}
\usage{
all_models_equal(..., verbose = FALSE)

all_models_same_class(..., verbose = FALSE)
}
\arguments{
\item{...}{A list of objects.}

\item{verbose}{Toggle off warnings.}
}
\value{
A logical, \code{TRUE} if \code{x} are all supported model objects
of same class.
}
\description{
Small helper that checks if all objects are \emph{supported}
(regression) model objects and of same class.
}
\examples{
\dontshow{if (require("lme4", quietly = TRUE)) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
data(mtcars)
data(sleepstudy, package = "lme4")

m1 <- lm(mpg ~ wt + cyl + vs, data = mtcars)
m2 <- lm(mpg ~ wt + cyl, data = mtcars)
m3 <- lme4::lmer(Reaction ~ Days + (1 | Subject), data = sleepstudy)
m4 <- glm(formula = vs ~ wt, family = binomial(), data = mtcars)

all_models_same_class(m1, m2)
all_models_same_class(m1, m2, m3)
all_models_same_class(m1, m4, m2, m3, verbose = TRUE)
all_models_same_class(m1, m4, mtcars, m2, m3, verbose = TRUE)
\dontshow{\}) # examplesIf}
}
