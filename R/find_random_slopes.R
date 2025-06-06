#' @title Find names of random slopes
#' @name find_random_slopes
#'
#' @description Return the name of the random slopes from mixed effects models.
#'
#' @param x A fitted mixed model.
#'
#' @return A list of character vectors with the name(s) of the random slopes, or
#' `NULL` if model has no random slopes. Depending on the model, the returned
#' list has following elements:
#'
#' - `random`, the random slopes from the conditional part of model
#' - `zero_inflated_random`, the random slopes from the zero-inflation component
#'   of the model. For **brms**, this is named `zi_random`.
#' - `dispersion_random`, the random slopes from the dispersion component of the
#'   model
#'
#' Models of class `brmsfit` may also contain elements for auxiliary parameters.
#'
#' @examplesIf require("lme4", quietly = TRUE)
#' data(sleepstudy, package = "lme4")
#' m <- lme4::lmer(Reaction ~ Days + (1 + Days | Subject), data = sleepstudy)
#' find_random_slopes(m)
#' @export
find_random_slopes <- function(x) {
  random_slopes <- vector(mode = "list")

  # do we already have a formula?
  if (inherits(x, "insight_formula")) {
    f <- x
    x <- NULL
    # random components in formulas end with "random"
    components <- names(f)[endsWith(names(f), "random")]
  } else {
    f <- find_formula(x, verbose = FALSE)
    # potential components that can have random effects
    components <- c("random", "zero_inflated_random")
  }

  # for brms, we can have random effects for auxilliary elements, too
  if (inherits(x, "brmsfit")) {
    components <- unique(c(components, names(f)[endsWith(names(f), "_random")]))
  }
  # for glmmTMB, we can have random effects for dispersion component, too
  if (inherits(x, "glmmTMB")) {
    components <- c(components, "dispersion_random")
  }

  # check which components we have
  components <- components[vapply(
    components,
    function(i) object_has_names(f, i),
    logical(1)
  )]

  # if nothing, return null
  if (!length(components)) {
    return(NULL)
  }

  random_slopes <- lapply(components, function(comp) {
    .extract_random_slopes(f[[comp]])
  })
  names(random_slopes) <- components
  random_slopes <- compact_list(random_slopes)

  if (is_empty_object(random_slopes)) {
    NULL
  } else {
    random_slopes
  }
}


.extract_random_slopes <- function(fr) {
  if (is.null(fr)) {
    return(NULL)
  }

  if (!is.list(fr)) fr <- list(fr)

  random_slope <- lapply(fr, function(f) {
    if (grepl("(.*)\\|(.*)\\|(.*)", safe_deparse(f))) {
      pattern <- "(.*)\\|(.*)\\|(.*)"
    } else {
      pattern <- "(.*)\\|(.*)"
    }
    pattern <- gsub(pattern, "\\1", safe_deparse(f))
    re <- all.vars(f)
    re[sapply(re, grepl, pattern, fixed = TRUE)]
  })

  unique(unlist(compact_list(random_slope)))
}
