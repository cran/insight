#' @title Get model parameters from generalized additive models
#' @name get_parameters.gamm
#'
#' @description Returns the coefficients from a model.
#'
#' @param ... Currently not used.
#'
#' @inheritParams find_predictors
#' @inheritParams find_parameters
#'
#' @inheritSection find_predictors Model components
#'
#' @return For models with smooth terms or zero-inflation component, a data
#'   frame with three columns: the parameter names, the related point estimates
#'   and the component.
#'
#' @examples
#' data(mtcars)
#' m <- lm(mpg ~ wt + cyl + vs, data = mtcars)
#' get_parameters(m)
#' @export
get_parameters.gamm <- function(x, component = "all", ...) {
  x <- x$gam
  class(x) <- c(class(x), c("glm", "lm"))
  get_parameters.gam(x, component, ...)
}


#' @export
get_parameters.Gam <- function(x, component = "all", ...) {
  component <- validate_argument(component, c("all", "conditional", "smooth_terms", "location"))
  pars <- stats::coef(x)

  .return_smooth_parms(
    conditional = pars[.grep_non_smoothers(names(pars))],
    smooth_terms = pars[.grep_smoothers(names(pars))],
    component = component
  )
}


#' @export
get_parameters.gam <- function(x, component = "all", ...) {
  component <- validate_argument(component, c("all", "conditional", "smooth_terms", "location"))
  pars <- stats::coef(x)

  st <- summary(x)$s.table
  smooth_terms <- st[, 1]
  names(smooth_terms) <- row.names(st)

  .return_smooth_parms(
    conditional = pars[.grep_non_smoothers(names(pars))],
    smooth_terms = smooth_terms,
    component = component
  )
}

#' @export
get_parameters.scam <- get_parameters.gam


#' @export
get_parameters.vgam <- function(x, component = "all", ...) {
  component <- validate_argument(component, c("all", "conditional", "smooth_terms", "location"))
  pars <- stats::coef(x)

  .return_smooth_parms(
    conditional = pars[.grep_non_smoothers(names(pars))],
    smooth_terms = pars[.grep_smoothers(names(pars))],
    component = component
  )
}


#' @export
get_parameters.gamlss <- function(x, ...) {
  pars <- lapply(x$parameters, function(i) {
    stats::na.omit(stats::coef(x, what = i))
  })

  names(pars) <- x$parameters
  if ("mu" %in% names(pars)) names(pars)[1] <- "conditional"

  do.call(rbind, lapply(names(pars), function(i) {
    params <- data.frame(
      Parameter = names(pars[[i]]),
      Estimate = pars[[i]],
      Component = i,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    text_remove_backticks(params)
  }))

  # data.frame(
  #   Parameter = c(names(pars$conditional), names(pars$sigma), names(pars$nu), names(pars$tau)),
  #   Estimate = c(unname(pars$conditional), unname(pars$sigma), unname(pars$nu), unname(pars$tau)),
  #   Component = c(
  #     rep("conditional", length(pars$conditional)),
  #     rep("sigma", length(pars$sigma)),
  #     rep("nu", length(pars$nu)),
  #     rep("tau", length(pars$tau))
  #   ),
  #   stringsAsFactors = FALSE,
  #   row.names = NULL
  # )
}


#' @export
get_parameters.rqss <- function(x, component = "all", ...) {
  component <- validate_argument(component, c("all", "conditional", "smooth_terms"))
  sc <- summary(x)

  smooth_terms <- sc$qsstab[, 1]
  names(smooth_terms) <- rownames(sc$qsstab)

  .return_smooth_parms(
    conditional = stats::setNames(sc$coef[, 1], rownames(sc$coef)),
    smooth_terms = smooth_terms,
    component = component
  )
}


#' @export
get_parameters.cgam <- function(x, component = "all", ...) {
  component <- validate_argument(component, c("all", "conditional", "smooth_terms"))
  sc <- summary(x)

  estimates <- sc$coefficients
  smooth_terms <- sc$coefficients2

  if (!is.null(smooth_terms)) smooth_terms <- stats::setNames(smooth_terms[, 1], rownames(smooth_terms))

  .return_smooth_parms(
    conditional = stats::setNames(estimates[, 1], rownames(estimates)),
    smooth_terms = smooth_terms,
    component = component
  )
}


#' @export
get_parameters.SemiParBIV <- function(x, ...) {
  s <- summary(x)
  s <- compact_list(s[startsWith(names(s), "tableP")])
  params <- do.call(rbind, lapply(seq_along(s), function(i) {
    out <- as.data.frame(s[[i]])
    out$Parameter <- rownames(out)
    out$Component <- paste0("Equation", i)
    out
  }))
  colnames(params)[1] <- "Estimate"
  rownames(params) <- NULL
  text_remove_backticks(params[c("Parameter", "Estimate", "Component")])
}


# helper -------------------


.return_smooth_parms <- function(conditional, smooth_terms, component) {
  if (is_empty_object(conditional)) {
    cond <- NULL
  } else {
    cond <- data.frame(
      Parameter = names(conditional),
      Estimate = conditional,
      Component = "conditional",
      stringsAsFactors = FALSE,
      row.names = NULL
    )
  }

  if (is_empty_object(smooth_terms)) {
    smooth_pars <- NULL
  } else {
    smooth_pars <- data.frame(
      Parameter = names(smooth_terms),
      Estimate = smooth_terms,
      Component = "smooth_terms",
      stringsAsFactors = FALSE,
      row.names = NULL
    )
  }

  pars <- switch(component,
    all = ,
    location = rbind(cond, smooth_pars),
    conditional = cond,
    smooth_terms = smooth_pars
  )

  if (!component %in% c("all", "location")) {
    pars <- .remove_column(pars, "Component")
  }

  text_remove_backticks(pars)
}
