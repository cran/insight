% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/format_table.R
\name{format_table}
\alias{format_table}
\title{Parameter table formatting}
\usage{
format_table(
  x,
  pretty_names = TRUE,
  stars = FALSE,
  stars_only = FALSE,
  digits = 2,
  ci_width = "auto",
  ci_brackets = TRUE,
  ci_digits = digits,
  p_digits = 3,
  rope_digits = digits,
  ic_digits = 1,
  zap_small = FALSE,
  preserve_attributes = FALSE,
  exact = TRUE,
  use_symbols = getOption("insight_use_symbols", FALSE),
  select = NULL,
  verbose = TRUE,
  ...
)
}
\arguments{
\item{x}{A data frame of model's parameters, as returned by various functions
of the \strong{easystats}-packages. May also be a result from
\code{broom::tidy()}.}

\item{pretty_names}{Return "pretty" (i.e. more human readable) parameter
names.}

\item{stars}{If \code{TRUE}, add significance stars (e.g., \verb{p < .001***}). Can
also be a character vector, naming the columns that should include stars
for significant values. This is especially useful for Bayesian models,
where we might have multiple columns with significant values, e.g. \code{BF}
for the Bayes factor or \code{pd} for the probability of direction. In such
cases, use \code{stars = c("pd", "BF")} to add stars to both columns, or
\code{stars = "BF"} to only add stars to the Bayes factor and exclude the \code{pd}
column. Currently, following columns are recognized: \code{"BF"}, \code{"pd"} and \code{"p"}.}

\item{stars_only}{If \code{TRUE}, return significant stars only (and no p-values).}

\item{digits, ci_digits, p_digits, rope_digits, ic_digits}{Number of digits for
rounding or significant figures. May also be \code{"signif"} to return significant
figures or \code{"scientific"} to return scientific notation. Control the
number of digits by adding the value as suffix, e.g. \code{digits = "scientific4"}
to have scientific notation with 4 decimal places, or \code{digits = "signif5"}
for 5 significant figures (see also \code{\link[=signif]{signif()}}).}

\item{ci_width}{Minimum width of the returned string for confidence
intervals. If not \code{NULL} and width is larger than the string's length,
leading whitespaces are added to the string. If \code{width="auto"}, width
will be set to the length of the longest string.}

\item{ci_brackets}{Logical, if \code{TRUE} (default), CI-values are
encompassed in square brackets (else in parentheses).}

\item{zap_small}{Logical, if \code{TRUE}, small values are rounded after
\code{digits} decimal places. If \code{FALSE}, values with more decimal
places than \code{digits} are printed in scientific notation.}

\item{preserve_attributes}{Logical, if \code{TRUE}, preserves all attributes
from the input data frame.}

\item{exact}{Formatting for Bayes factor columns, in case the provided data
frame contains such a column (i.e. columns named \code{"BF"} or \code{"log_BF"}).
For \code{exact = TRUE}, very large or very small values are then either reported
with a scientific format (e.g., 4.24e5), else as truncated values (as "> 1000"
and "< 1/1000").}

\item{use_symbols}{Logical, if \code{TRUE}, column names that refer to particular
effectsizes (like Phi, Omega or Epsilon) include the related unicode-character
instead of the written name. This only works on Windows for R >= 4.2, and on
OS X or Linux for R >= 4.0. It is possible to define a global option for this
setting, see 'Note'.}

\item{select}{Determines which columns are printed and the table layout.
There are two options for this argument:
\itemize{
\item \strong{A string expression with layout pattern}

\code{select} is a string with "tokens" enclosed in braces. These tokens will be
replaced by their associated columns, where the selected columns will be
collapsed into one column. Following tokens are replaced by the related
coefficients or statistics: \code{{estimate}}, \code{{se}}, \code{{ci}} (or \code{{ci_low}} and
\code{{ci_high}}), \code{{p}}, \code{{pd}} and \code{{stars}}. The token \code{{ci}} will be replaced
by \verb{\{ci_low\}, \{ci_high\}}. Example: \code{select = "{estimate}{stars} ({ci})"}

It is possible to create multiple columns as well. A \code{|} separates values
into new cells/columns. Example: \code{select = "{estimate} ({ci})|{p}"}.
\item \strong{A string indicating a pre-defined layout}

\code{select} can be one of the following string values, to create one of the
following pre-defined column layouts:
\itemize{
\item \code{"minimal"}: Estimates, confidence intervals and numeric p-values, in two
columns. This is equivalent to \code{select = "{estimate} ({ci})|{p}"}.
\item \code{"short"}: Estimate, standard errors and numeric p-values, in two columns.
This is equivalent to \code{select = "{estimate} ({se})|{p}"}.
\item \code{"ci"}: Estimates and confidence intervals, no asterisks for p-values.
This is equivalent to \code{select = "{estimate} ({ci})"}.
\item \code{"se"}: Estimates and standard errors, no asterisks for p-values. This is
equivalent to \code{select = "{estimate} ({se})"}.
\item \code{"ci_p"}: Estimates, confidence intervals and asterisks for p-values. This
is equivalent to \code{select = "{estimate}{stars} ({ci})"}.
\item \code{"se_p"}: Estimates, standard errors and asterisks for p-values. This is
equivalent to \code{select = "{estimate}{stars} ({se})"}..
}
}

Using \code{select} to define columns will re-order columns and remove all columns
related to uncertainty (standard errors, confidence intervals), test statistics,
and p-values (and similar, like \code{pd} or \code{BF} for Bayesian models), because
these are assumed to be included or intentionally excluded when using \code{select}.
The new column order will be: Parameter columns first, followed by the "glue"
columns, followed by all remaining columns. If further columns should also be
placed first, add those as \code{focal_terms} attributes to \code{x}. I.e., following
columns are considers as "parameter columns" and placed first:
\code{c(easystats_columns("parameter"), attributes(x)$focal_terms)}.

\strong{Note:} glue-like syntax is still experimental in the case of more complex models
(like mixed models) and may not return expected results.}

\item{verbose}{Toggle messages and warnings.}

\item{...}{Arguments passed to or from other methods.}
}
\value{
A data frame. Note that \code{format_table()} converts all columns
into character vectors!
}
\description{
This functions takes a data frame (usually with model
parameters) as input and formats certain columns into a more readable
layout (like collapsing separate columns for lower and upper confidence
interval values). Furthermore, column names are formatted as well. Note
that \code{format_table()} converts all columns into character vectors!
}
\note{
\code{options(insight_use_symbols = TRUE)} overrides the \code{use_symbols} argument
and always displays symbols, if possible.
}
\examples{
\dontshow{if (require("rstanarm", warn.conflicts = FALSE) && require("parameters", warn.conflicts = FALSE) && packageVersion("parameters") > "0.22.2") (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
format_table(head(iris), digits = 1)

m <- lm(Sepal.Length ~ Species * Sepal.Width, data = iris)
x <- parameters::model_parameters(m)
as.data.frame(format_table(x))
as.data.frame(format_table(x, p_digits = "scientific"))
# "glue" columns
as.data.frame(format_table(x, select = "minimal"))
as.data.frame(format_table(x, select = "{estimate}{stars}|{p}"))

\donttest{
model <- rstanarm::stan_glm(
  Sepal.Length ~ Species,
  data = iris,
  refresh = 0,
  seed = 123
)
x <- parameters::model_parameters(model, ci = c(0.69, 0.89, 0.95))
as.data.frame(format_table(x))
}
\dontshow{\}) # examplesIf}
}
\seealso{
Vignettes
\href{https://easystats.github.io/insight/articles/display.html}{Formatting, printing and exporting tables}
and \href{https://easystats.github.io/parameters/articles/model_parameters_formatting.html}{Formatting model parameters}.
}
