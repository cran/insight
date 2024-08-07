#' @title Return function of transformed response variables
#' @name get_transformation
#'
#' @description
#'
#' This functions checks whether any transformation, such as log- or
#' exp-transforming, was applied to the response variable (dependent variable)
#' in a regression formula, and returns the related function that was used for
#' transformation.
#'
#' @param x A regression model.
#' @param verbose Logical, if `TRUE`, prints a warning if the transformation
#' could not be determined.
#'
#' @return
#'
#' A list of two functions: `$transformation`, the function that was used to
#' transform the response variable; `$inverse`, the inverse-function of
#' `$transformation` (can be used for "back-transformation"). If no
#' transformation was applied, both list-elements `$transformation` and
#' `$inverse` just return `function(x) x`. If transformation is unknown,
#' `NULL` is returned.
#'
#' @examples
#' # identity, no transformation
#' model <- lm(Sepal.Length ~ Species, data = iris)
#' get_transformation(model)
#'
#' # log-transformation
#' model <- lm(log(Sepal.Length) ~ Species, data = iris)
#' get_transformation(model)
#'
#' # log-function
#' get_transformation(model)$transformation(0.3)
#' log(0.3)
#'
#' # inverse function is exp()
#' get_transformation(model)$inverse(0.3)
#' exp(0.3)
#' @export
get_transformation <- function(x, verbose = TRUE) {
  transform_fun <- find_transformation(x)

  # unknown
  if (is.null(transform_fun)) {
    return(NULL)
  }

  if (transform_fun == "identity") {
    out <- list(transformation = function(x) x, inverse = function(x) x)
  } else if (transform_fun == "log") {
    out <- list(transformation = log, inverse = exp)
  } else if (transform_fun %in% c("log1p", "log(x+1)")) {
    out <- list(transformation = log1p, inverse = expm1)
  } else if (transform_fun == "log10") {
    out <- list(transformation = log10, inverse = function(x) 10^x)
  } else if (transform_fun == "log2") {
    out <- list(transformation = log2, inverse = function(x) 2^x)
  } else if (transform_fun == "exp") {
    out <- list(transformation = exp, inverse = log)
  } else if (transform_fun == "sqrt") {
    out <- list(transformation = sqrt, inverse = function(x) x^2)
  } else if (transform_fun == "inverse") {
    out <- list(transformation = function(x) 1 / x, inverse = function(x) x^-1)
  } else if (transform_fun == "power") {
    ## TODO: detect power - can we turn this into a generic function?
    trans_power <- .safe(gsub("\\(|\\)", "", gsub("(.*)(\\^|\\*\\*)\\s*(\\d+|[()])", "\\3", find_terms(x)[["response"]]))) # nolint
    if (is.null(trans_power)) {
      trans_power <- "2"
    }
    out <- switch(trans_power,
      `0.5` = list(transformation = function(x) x^0.5, inverse = function(x) x^2),
      `3` = list(transformation = function(x) x^3, inverse = function(x) x^(1 / 3)),
      `4` = list(transformation = function(x) x^4, inverse = function(x) x^0.25),
      `5` = list(transformation = function(x) x^5, inverse = function(x) x^0.2),
      list(transformation = function(x) x^2, inverse = sqrt)
    )
  } else if (transform_fun == "expm1") {
    out <- list(transformation = expm1, inverse = log1p)
  } else if (transform_fun == "log-log") {
    out <- list(
      transformation = function(x) log(log(x)),
      inverse = function(x) exp(exp(x))
    )
  } else {
    if (verbose) {
      insight::format_alert(
        paste0("The transformation and inverse-transformation functions for `", transform_fun, "` could not be determined.") # nolint
      )
    }
    out <- NULL
  }

  out
}
