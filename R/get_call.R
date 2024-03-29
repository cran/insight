#' @title Get the model's function call
#' @name get_call
#'
#' @description Returns the model's function call when available.
#'
#' @inheritParams find_random
#'
#' @return A function call.
#'
#' @examplesIf require("lme4", quietly = TRUE)
#' data(mtcars)
#' m <- lm(mpg ~ wt + cyl + vs, data = mtcars)
#' get_call(m)
#'
#' m <- lme4::lmer(Sepal.Length ~ Sepal.Width + (1 | Species), data = iris)
#' get_call(m)
#' @export
get_call <- function(x) {
  UseMethod("get_call")
}


#' @export
get_call.default <- function(x) {
  cl <- .safe(getElement(x, "call"))
  # For GAMM4
  if (is.null(cl) && "gam" %in% names(x)) {
    # Where's the call here?
    cl <- .safe(x$gam$formula)
  }
  cl
}

#' @export
get_call.lm <- function(x) {
  x$call
}

#' @export
get_call.glm <- get_call.lm

#' @export
get_call.mvord <- function(x) {
  x$rho$mc
}

#' @export
get_call.model_fit <- function(x) {
  get_call(x$fit)
}

#' @export
get_call.lmerMod <- function(x) {
  x@call
}

#' @export
get_call.merMod <- get_call.lmerMod

#' @export
get_call.stanreg <- function(x) {
  x$call
}
