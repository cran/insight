#' @rdname find_parameters.BGGM
#' @export
find_parameters.brmsfit <- function(x,
                                    effects = "all",
                                    component = "all",
                                    flatten = FALSE,
                                    parameters = NULL,
                                    ...) {
  effects <- validate_argument(
    effects,
    c("all", "fixed", "random", "random_variance", "grouplevel", "full")
  )
  component <- validate_argument(
    component,
    c(
      "all", "conditional", "zi", "zero_inflated", "dispersion", "instruments",
      "correlation", "smooth_terms", "location", "auxiliary", "distributional"
    )
  )

  fe <- dimnames(x$fit)$parameters

  # remove redundant columns. These seem to be new since brms 2.16?
  pattern <- "^[A-z]_\\d\\.\\d\\.(.*)"
  fe <- fe[!grepl(pattern, fe)]

  is_mv <- NULL

  # remove "Intercept"
  fe <- fe[!startsWith(fe, "Intercept")]

  # extract all components, including custom and auxiliary ones
  dpars <- find_auxiliary(x, add_alias = TRUE)

  # elements to return
  elements <- .brms_elements(effects, component, dpars)

  if (is_multivariate(x)) {
    rn <- names(find_response(x))
    l <- lapply(
      rn,
      .brms_parameters,
      fe = fe,
      dpars = dpars,
      elements = elements,
      effects = effects
    )
    names(l) <- rn
    is_mv <- "1"
  } else {
    l <- .brms_parameters(fe, dpars, elements, effects)
  }

  l <- .filter_pars(l, parameters, !is.null(is_mv) && is_mv == "1")
  attr(l, "is_mv") <- is_mv

  if (flatten) {
    unique(unlist(l, use.names = FALSE))
  } else {
    l
  }
}


# utilities ------------------------------------------------------------


.brms_elements <- function(effects, component, dpars) {
  # elements to return
  elements <- .get_elements(effects = effects, component = component)

  # add custom (dpars) elements
  if (component %in% c("all", "auxiliary", "distributional")) {
    elements <- unique(c(elements, dpars))
  }

  # add priors
  elements <- c(elements, "priors")

  # add random effects
  if (effects != "fixed") {
    elements <- unique(c(elements, paste0(elements, "_random")))
  }

  # remove random effects or keep them only
  switch(effects,
    fixed = elements[!endsWith(elements, "random")],
    grouplevel = ,
    random_variance = ,
    random = elements[endsWith(elements, "random")],
    elements
  )
}


.brms_parameters <- function(fe, dpars, elements, effects = "full", mv_response = NULL) {
  # dpars: names of `$pforms` element, which includes the names of
  #        all auxiliary parameters
  #
  # create pattern for grouping dpars
  dpars_pattern <- paste(dpars, collapse = "|")

  # special pattern for multivariate models
  if (is.null(mv_response)) {
    mv_pattern_fixed <- mv_pattern_random <- mv_pattern_dpars <- mv_pattern_sigma <- ""
    mv_pattern_random_dpars <- "\\["
  } else {
    mv_pattern_fixed <- sprintf("(\\Q%s\\E_)", mv_response)
    mv_pattern_random_dpars <- mv_pattern_random <- sprintf("(_\\Q%s\\E)(_|\\[)", mv_response)
    mv_pattern_dpars <- sprintf("(\\Q%s\\E_)", mv_response)
    mv_pattern_sigma <- sprintf("\\Q%s\\E", mv_response)
  }

  # flag to indicate which parameters are auxiliary parameters
  if (isTRUE(nzchar(dpars_pattern))) {
    dpars_params <- grepl(paste0("__(", dpars_pattern, ")"), fe)
  } else {
    dpars_params <- rep_len(FALSE, length(fe))
  }

  # extract conditional fixed effects
  pattern <- "^(b_|bs_|bsp_|bcs_)"
  # need to add negative look ahead for auxiliary, *if we have any*!
  if (isTRUE(nzchar(dpars_pattern))) {
    pattern <- paste0(pattern, "(?!", dpars_pattern, ")")
  }
  pattern <- paste0(pattern, mv_pattern_fixed, "(.*)")
  cond <- fe[grepl(pattern, fe, perl = TRUE)]

  # conditional random
  pattern <- paste0("^r_(.*)", mv_pattern_random)
  rand <- fe[grepl(pattern, fe, perl = TRUE) & !startsWith(fe, "prior_") & !dpars_params]
  pattern <- paste0("^sd_(.*)", mv_pattern_random)
  rand_sd <- fe[grepl(pattern, fe, perl = TRUE) & !dpars_params]
  pattern <- paste0("^cor_(.*)", mv_pattern_random)
  rand_cor <- fe[grepl(pattern, fe, perl = TRUE) & !dpars_params]

  # special formula functions
  simo <- fe[startsWith(fe, "simo_")]
  car_struc <- fe[fe %in% c("car", "sdcar")]
  smooth_terms <- fe[startsWith(fe, "sds_")]
  priors <- fe[startsWith(fe, "prior_")]
  shiftprop <- fe[grepl("shiftprop", fe, fixed = TRUE)]
  mix <- fe[grepl("mix", fe, fixed = TRUE)]
  dispersion <- fe[grepl("dispersion", fe, fixed = TRUE)]

  # combine random effects elements for conditional component
  cond_random <- c(rand, rand_sd, rand_cor, car_struc)

  # check whether group level effects should be returned or not.
  cond_random <- switch(effects,
    all = ,
    fixed = ,
    random_variance = cond_random[!startsWith(cond_random, "r_")],
    grouplevel = cond_random[startsWith(cond_random, "r_")],
    cond_random
  )

  dpars_fixed <- list()
  dpars_random <- list()

  # build parameter lists for all dpars
  for (dp in dpars) {
    random_dp <- NULL
    # fixed
    if (dp == "sigma") {
      # exception: sigma
      dpars_fixed[[dp]] <- fe[fe == "sigma"]
      pattern <- paste0("^sigma_", mv_pattern_sigma)
      dpars_fixed[[dp]] <- c(dpars_fixed[[dp]], grep(pattern, fe, value = TRUE))
      pattern <- paste0("^(b_", dp, "_|bs_", dp, "_|bsp_", dp, "_|bcs_", dp, ")", mv_pattern_sigma)
      dpars_fixed[[dp]] <- c(dpars_fixed[[dp]], grep(pattern, fe, value = TRUE))
    } else {
      pattern <- paste0("^(b_", dp, "_|bs_", dp, "_|bsp_", dp, "_|bcs_", dp, ")", mv_pattern_fixed)
      dpars_fixed[[dp]] <- grep(pattern, fe, value = TRUE)
    }
    # random
    pattern <- paste0("^r_(.*__", dp, ")", mv_pattern_random_dpars)
    random_dp <- c(random_dp, grep(pattern, fe, value = TRUE))
    pattern <- paste0("^sd_(.*_", dp, "_)", mv_pattern_dpars)
    random_dp <- c(random_dp, grep(pattern, fe, value = TRUE))
    pattern <- paste0("^cor_(.*_", dp, "_)", mv_pattern_dpars)
    random_dp <- c(random_dp, grep(pattern, fe, value = TRUE))
    dpars_random[[dp]] <- compact_character(random_dp)

    # check whether group level effects should be returned or not.
    dpars_random[[dp]] <- switch(effects,
      all = ,
      fixed = ,
      random_variance = dpars_random[[dp]][!startsWith(dpars_random[[dp]], "r_")],
      grouplevel = dpars_random[[dp]][startsWith(dpars_random[[dp]], "r_")],
      dpars_random[[dp]]
    )
  }

  # find names of random dpars that do not have the suffix "_random", and add it
  if (length(dpars_random)) {
    no_suffix <- !endsWith(names(dpars_random), "_random")
    names(dpars_random)[no_suffix] <- paste0(names(dpars_random)[no_suffix], "_random")
  }

  compact_list(c(
    list(conditional = cond, random = cond_random),
    dpars_fixed,
    dpars_random
  )[elements])
}
