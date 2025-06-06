#' @title Get model parameters from marginal effects models
#' @name get_parameters.betamfx
#'
#' @description Returns the coefficients from a model.
#'
#' @param ... Currently not used.
#'
#' @inheritParams find_parameters
#' @inheritParams find_predictors
#'
#' @inheritSection find_predictors Model components
#'
#' @return A data frame with three columns: the parameter names, the related
#'   point estimates and the component.
#'
#' @examples
#' data(mtcars)
#' m <- lm(mpg ~ wt + cyl + vs, data = mtcars)
#' get_parameters(m)
#' @export
get_parameters.betamfx <- function(x, component = "all", ...) {
  component <- validate_argument(
    component,
    c("all", "conditional", "precision", "marginal")
  )
  params <- get_parameters.betareg(x$fit, component = "all", ...)
  mfx <- x$mfxest

  params <- rbind(
    data.frame(
      Parameter = gsub("^\\(phi\\)_", "", rownames(mfx)),
      Estimate = as.vector(mfx[, 1]),
      Component = "marginal",
      stringsAsFactors = FALSE
    ),
    params
  )

  if (component != "all") {
    params <- params[params$Component == component, , drop = FALSE]
  }

  text_remove_backticks(params)
}


#' @export
get_parameters.betaor <- function(x, component = "all", ...) {
  component <- validate_argument(component, c("all", "conditional", "precision"))
  get_parameters.betareg(x$fit, component = component, ...)
}


#' @export
get_parameters.logitmfx <- function(x, component = "all", ...) {
  params <- get_parameters.default(x$fit, ...)
  params$Component <- "conditional"
  mfx <- x$mfxest

  params <- rbind(
    data.frame(
      Parameter = rownames(mfx),
      Estimate = as.vector(mfx[, 1]),
      Component = "marginal",
      stringsAsFactors = FALSE
    ),
    params
  )

  component <- validate_argument(component, c("all", "conditional", "marginal"))
  if (component != "all") {
    params <- params[params$Component == component, , drop = FALSE]
  }

  text_remove_backticks(params)
}

#' @export
get_parameters.poissonmfx <- get_parameters.logitmfx

#' @export
get_parameters.negbinmfx <- get_parameters.logitmfx

#' @export
get_parameters.probitmfx <- get_parameters.logitmfx

#' @export
get_parameters.logitor <- function(x, ...) {
  get_parameters.default(x$fit, ...)
}

#' @export
get_parameters.poissonirr <- get_parameters.logitor

#' @export
get_parameters.negbinirr <- get_parameters.logitor
