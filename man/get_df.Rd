% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_df.R
\name{get_df}
\alias{get_df}
\alias{get_df.default}
\title{Extract degrees of freedom}
\usage{
get_df(x, ...)

\method{get_df}{default}(x, type = "residual", verbose = TRUE, ...)
}
\arguments{
\item{x}{A statistical model.}

\item{...}{Currently not used.}

\item{type}{Type of approximation for the degrees of freedom. Can be one of
the following:
\itemize{
\item \code{"residual"} (aka \code{"analytical"}) returns the residual degrees of
freedom, which usually is what \code{\link[stats:df.residual]{stats::df.residual()}} returns. If a
model object has no method to extract residual degrees of freedom, these
are calculated as \code{n-p}, i.e. the number of observations minus the number
of estimated parameters. If residual degrees of freedom cannot be extracted
by either approach, returns \code{Inf}.
\item \code{"wald"} returns residual (aka analytical) degrees of freedom for models
with t-statistic, \code{1} for models with Chi-squared statistic, and \code{Inf} for
all other models. Also returns \code{Inf} if residual degrees of freedom cannot
be extracted.
\item \code{"normal"} always returns \code{Inf}.
\item \code{"model"} returns model-based degrees of freedom, i.e. the number of
(estimated) parameters.
\item For mixed models, can also be \code{"ml1"} (or \code{"m-l-1"}, approximation of
degrees of freedom based on a "m-l-1" heuristic as suggested by \emph{Elff et
al. 2019}) or \code{"between-within"} (or \code{"betwithin"}).
\item For mixed models of class \code{merMod}, \code{type} can also be \code{"satterthwaite"}
or \code{"kenward-roger"} (or \code{"kenward"}). See 'Details'.
}

Usually, when degrees of freedom are required to calculate p-values or
confidence intervals, \code{type = "wald"} is likely to be the best choice in
most cases.}

\item{verbose}{Toggle warnings.}
}
\description{
Estimate or extract residual or model-based degrees of freedom
from regression models.
}
\details{
\strong{Degrees of freedom for mixed models}

Inferential statistics (like p-values, confidence intervals and
standard errors) may be biased in mixed models when the number of clusters
is small (even if the sample size of level-1 units is high). In such cases
it is recommended to approximate a more accurate number of degrees of freedom
for such inferential statistics (see \emph{Li and Redden 2015}).

\emph{m-l-1 degrees of freedom}

The \emph{m-l-1} heuristic is an approach that uses a t-distribution with fewer
degrees of freedom. In particular for repeated measure designs (longitudinal
data analysis), the m-l-1 heuristic is likely to be more accurate than simply
using the residual or infinite degrees of freedom, because \code{get_df(type = "ml1")}
returns different degrees of freedom for within-cluster and between-cluster
effects. Note that the "m-l-1" heuristic is not applicable (or at least less
accurate) for complex multilevel designs, e.g. with cross-classified clusters.
In such cases, more accurate approaches like the Kenward-Roger approximation
is recommended. However, the "m-l-1" heuristic also applies to generalized
mixed models, while approaches like Kenward-Roger or Satterthwaite are limited
to linear mixed models only.

\emph{Between-within degrees of freedom}

The Between-within denominator degrees of freedom approximation is, similar
to the "m-l-1" heuristic, recommended in particular for (generalized) linear
mixed models with repeated measurements (longitudinal design).
\code{get_df(type = "betwithin")} implements a heuristic based on the between-within
approach, i.e. this type returns different degrees of freedom for within-cluster
and between-cluster effects. Note that this implementation does not return
exactly the same results as shown in \emph{Li and Redden 2015}, but similar.

\emph{Satterthwaite and Kenward-Rogers degrees of freedom}

Unlike simpler approximation heuristics like the "m-l-1" rule (\code{type = "ml1"}),
the Satterthwaite or Kenward-Rogers approximation is also applicable in more
complex multilevel designs. However, the "m-l-1" or "between-within" heuristics
also apply to generalized mixed models, while approaches like Kenward-Roger
or Satterthwaite are limited to linear mixed models only.
}
\examples{
model <- lm(Sepal.Length ~ Petal.Length * Species, data = iris)
get_df(model) # same as df.residual(model)
get_df(model, type = "model") # same as attr(logLik(model), "df")
}
\references{
\itemize{
\item Kenward, M. G., & Roger, J. H. (1997). Small sample inference for
fixed effects from restricted maximum likelihood. Biometrics, 983-997.
\item Satterthwaite FE (1946) An approximate distribution of estimates of
variance components. Biometrics Bulletin 2 (6):110–4.
\item Elff, M.; Heisig, J.P.; Schaeffer, M.; Shikano, S. (2019). Multilevel
Analysis with Few Clusters: Improving Likelihood-based Methods to Provide
Unbiased Estimates and Accurate Inference, British Journal of Political
Science.
\item Li, P., Redden, D. T. (2015). Comparing denominator degrees of freedom
approximations for the generalized linear mixed model in analyzing binary
outcome in small sample cluster-randomized trials. BMC Medical Research
Methodology, 15(1), 38
}
}
