#' @title Get auxiliary parameters from models
#'
#' @description Returns the requested auxiliary parameters from models, like
#' dispersion, sigma, or beta...
#'
#' @name get_auxiliary
#'
#' @param x A model.
#' @param type The name of the auxiliary parameter that should be retrieved.
#' `"sigma"` is available for most models, `"dispersion"` for models
#' of class `glm`, `glmerMod` or `glmmTMB` as well as `brmsfit`.
#' `"beta"` and other parameters are currently only returned for `brmsfit`
#' models. See 'Details'.
#' @param verbose Toggle warnings.
#' @param ... Currently not used.
#' @inheritParams get_parameters.BGGM
#'
#' @return The requested auxiliary parameter, or `NULL` if this information
#' could not be accessed.
#'
#' @details Currently, only sigma and the dispersion parameter are returned, and
#' only for a limited set of models.
#'
#' @section Sigma Parameter:
#'
#' See [`get_sigma()`].
#'
#' @section  Dispersion Parameter:
#'
#' There are many different definitions of "dispersion", depending on the context.
#' `get_auxiliary()` returns the dispersion parameters that usually can
#' be considered as variance-to-mean ratio for generalized (linear) mixed
#' models. Exceptions are models of class `glmmTMB`, where the dispersion
#' equals \ifelse{html}{\out{&sigma;<sup>2</sup>}}{\eqn{\sigma^2}}.
#' In detail, the computation of the dispersion parameter for generalized linear
#' models is the ratio of the sum of the squared working-residuals and the
#' residual degrees of freedom. For mixed models of class `glmer`, the
#' dispersion parameter is also called \ifelse{html}{\out{&phi;}}{\eqn{\phi}}
#' and is the ratio of the sum of the squared Pearson-residuals and the residual
#' degrees of freedom. For models of class `glmmTMB`, dispersion is
#' \ifelse{html}{\out{&sigma;<sup>2</sup>}}{\eqn{\sigma^2}}.
#'
#' @section  brms-models:
#'
#' For models of class `brmsfit`, there are different options for the
#' `type` argument. See a list of supported auxiliary parameters here:
#' [`find_parameters.BGGM()`].
#'
#' @examples
#' # from ?glm
#' clotting <- data.frame(
#'   u = c(5, 10, 15, 20, 30, 40, 60, 80, 100),
#'   lot1 = c(118, 58, 42, 35, 27, 25, 21, 19, 18),
#'   lot2 = c(69, 35, 26, 21, 18, 16, 13, 12, 12)
#' )
#' model <- glm(lot1 ~ log(u), data = clotting, family = Gamma())
#' get_auxiliary(model, type = "dispersion") # same as summary(model)$dispersion
#' @export
get_auxiliary <- function(x,
                          type = "sigma",
                          summary = TRUE,
                          centrality = "mean",
                          verbose = TRUE,
                          ...) {
  type <- validate_argument(
    type,
    unique(c(.aux_elements(), .brms_aux_elements(), "all"))
  )

  if (inherits(x, "brmsfit")) {
    return(.get_generic_aux(x, type, summary = summary, centrality = centrality))
  } else if (type == "sigma") {
    return(as.numeric(get_sigma(x)))
  } else if (type == "dispersion") {
    return(get_dispersion(x))
  } else {
    return(NULL)
  }
}


# dispersion parameter -----------------------

#' @rdname get_auxiliary
#' @export
get_dispersion <- function(x, ...) {
  UseMethod("get_dispersion")
}

#' @rdname get_auxiliary
#' @export
get_dispersion.default <- function(x, ...) {
  format_error(sprintf("`get_dispersion()` does not yet support models of class \"%s\".", class(x)[1])) # nolint
}

#' @export
get_dispersion.model_fit <- function(x, ...) {
  get_dispersion(x$fit, ...)
}

#' @export
get_dispersion.glm <- function(x, verbose = TRUE, ...) {
  info <- model_info(x, verbose = verbose)
  disp <- NULL

  if (info$is_poisson || info$is_binomial || info$is_negbin) {
    disp <- 1
  } else {
    working_weights <- get_weights(x, type = "working")
    working_res <- as.vector(get_residuals(x, type = "working"))^2 * working_weights
    disp <- sum(working_res[working_weights > 0]) / get_df(x, type = "residual")
  }
  disp
}

#' @export
get_dispersion.glmerMod <- function(x, verbose = TRUE, ...) {
  info <- model_info(x, verbose = verbose)
  disp <- NULL

  if (info$is_poisson || info$is_binomial || info$is_negbin) {
    disp <- 1
  } else {
    # see http://bbolker.github.io/mixedmodels-misc/glmmFAQ.html#fitting-models-with-overdispersion
    # phi is the dispersion factor, and phi is usually "sigma^2"
    # (https://stat.ethz.ch/pipermail/r-sig-mixed-models/2017q4/026168.html)
    # or the following ratio:
    res_df <- get_df(x, type = "residual")
    p_res <- get_residuals(x, type = "pearson")
    disp <- sum(p_res^2) / res_df
  }
  disp
}

#' @export
get_dispersion.glmmTMB <- function(x, verbose = TRUE, ...) {
  info <- model_info(x, verbose = verbose)
  disp <- NULL

  if (info$is_poisson || info$is_binomial || info$is_negbin) {
    disp <- 1
  } else {
    disp <- as.numeric(get_sigma(x))^2
  }
  disp
}

#' @export
get_dispersion.brmsfit <- get_dispersion.glmmTMB


# special ------------------

#' @keywords internal
.get_generic_aux <- function(x,
                             param,
                             summary = TRUE,
                             centrality = "mean",
                             ...) {
  aux <- NULL
  if (inherits(x, "brmsfit")) {
    if (all(param == "all")) {
      param <- find_auxiliary(x)
    }
    # get posterior draws
    aux <- as.data.frame(x)
    # find parameter names of distributional parameters
    param_names <- unlist(find_parameters(x)[param], use.names = FALSE)
    # intersect only available columns
    param <- intersect(param_names, colnames(aux))
    # check if any distributional parameter available
    if (is.null(param) || !length(param)) {
      format_warning(paste0("No auxiliary parameters found."))
      return(NULL)
    }
    aux <- aux[param]
    if (summary) {
      aux <- .summary_of_posteriors(aux, centrality = centrality)
    }
  }

  aux
}
