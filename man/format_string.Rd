% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/format_string.R
\name{format_string}
\alias{format_string}
\alias{format_string.character}
\title{String Values Formatting}
\usage{
format_string(x, ...)

\method{format_string}{character}(x, length = NULL, abbreviate = "...", ...)
}
\arguments{
\item{x}{String value.}

\item{...}{Arguments passed to or from other methods.}

\item{length}{Numeric, maximum length of the returned string. If not
\code{NULL}, will shorten the string to a maximum \code{length}, however,
it will not truncate inside words. I.e. if the string length happens to be
inside a word, this word is removed from the returned string, so the
returned string has a \emph{maximum} length of \code{length}, but might be
shorter.}

\item{abbreviate}{String that will be used as suffix, if \code{x} was
shortened.}
}
\value{
A formatted string.
}
\description{
String Values Formatting
}
\examples{
s <- "This can be considered as very long string!"
# string is shorter than max.length, so returned as is
format_string(s, 60)

# string is shortened to as many words that result in
# a string of maximum 20 chars
format_string(s, 20)
}
