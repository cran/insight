#' @title Checks if an object is a regression model or statistical test object
#' @name is_model
#'
#' @description Small helper that checks if a model is a regression model or
#'   a statistical object. \code{is_regression_model()} is stricter and only
#'   returns \code{TRUE} for regression models, but not for, e.g., \code{htest}
#'   objects.
#'
#' @param x An object.
#'
#' @return A logical, \code{TRUE} if \code{x} is a (supported) model object.
#'
#' @details This function returns \code{TRUE} if \code{x} is a model object.
#'
#' @examples
#' data(mtcars)
#' m <- lm(mpg ~ wt + cyl + vs, data = mtcars)
#'
#' is_model(m)
#' is_model(mtcars)
#'
#' test <- t.test(1:10, y = c(7:20))
#' is_model(test)
#' is_regression_model(test)
#' @export
is_model <- function(x) {
  inherits(.get_class_list(x), .get_model_classes())
}


# Is regression model -----------------------------------------------------

#' @rdname is_model
#' @export
is_regression_model <- function(x) {
  inherits(.get_class_list(x), .get_model_classes(regression_only = TRUE))
}


# Helpers -----------------------------------------------------------------

.get_class_list <- function(x) {
  if(length(class(x)) > 1 || class(x) != "list") return(x)

  if(all(c("mer", "gam") %in% names(x))) {
    class(x) <- c("gamm4", "list")
  }
  x
}


.get_model_classes <- function(regression_only = FALSE) {
  out <- c(
    "_ranger",
    "aareg",
    "afex_aov",
    "ancova",
    "anova",
    "Anova.mlm",
    "aov",
    "aovlist",
    "Arima",
    "averaging",
    "bamlss",
    "bamlss.frame",
    "bayesGAM",
    "bayesmeta",
    "bayesx",
    "bayesQR",
    "BBmm",
    "BBreg",
    "bcplm",
    "betamfx",
    "betaor",
    "betareg",
    "BFBayesFactor",
    "BGGM",
    "bglmerMod",
    "bife",
    "biglm",
    "bigglm",
    "blrm",
    "blavaan",
    "blmerMod",
    "boot_test_mediation",
    "bracl",
    "brglm",
    "brglmFit",
    "brmsfit",
    "brmultinom",
    "bsem",
    "btergm",
    "cch",
    "censReg",
    "cgam",
    "cgamm",
    "cglm",
    "clm",
    "clm2",
    "clmm",
    "clmm2",
    "clogit",
    "coeftest",
    "complmrob",
    "comprisk",
    "confusionMatrix",
    "coxme",
    "coxph",
    "coxph.penal",
    "coxr",
    "cpglm",
    "cpglmm",
    "crch",
    "crq",
    "crqs",
    "crr",
    "dglm",
    "DirichletRegModel",
    "drc",
    "eglm",
    "elm",
    "emmGrid",
    "emm_list",
    "epi.2by2",
    "ergm",
    "feglm",
    "feis",
    "felm",
    "fitdistr",
    "fixest",
    "flexmix",
    "flexsurvreg",
    "gam",
    "Gam",
    "GAMBoost",
    "gamlr",
    "gamlss",
    "gamm",
    "gamm4",
    "garch",
    "gbm",
    "gee",
    "geeglm",
    "glht",
    "glimML",
    "Glm",
    "glm",
    "glmaag",
    "glmbb",
    "glmboostLSS",
    "glmc",
    "glmdm",
    "glmdisc",
    "glmerMod",
    "glmlep",
    "glmm",
    "glmmadmb",
    "glmmEP",
    "glmmfields",
    "glmmLasso",
    "glmmPQL",
    "glmmTMB",
    "glmnet",
    "glmrob",
    "glmRob",
    "glmx",
    "gls",
    "gmnl",
    "gmm",
    "gsm",
    "heavyLme",
    "HLfit",
    "htest",
    "hurdle",
    "ivFixed",
    "iv_robust",
    "ivreg",
    "ivprobit",
    "lavaan",
    "lm",
    "lm_robust",
    "lme",
    "lmrob",
    "lmRob",
    "loggammacenslmrob",
    "logistf",
    "LogitBoost",
    "loo",
    "LORgee",
    "lmodel2",
    "lmerMod",
    "lmerModLmerTest",
    "logitmfx",
    "logitor",
    "lqm",
    "lqmm",
    "lrm",
    "maov",
    "manova",
    "MANOVA",
    "margins",
    "maxLik",
    "mboostLSS",
    "mclogit",
    "mcp1",
    "mcp2",
    "mmclogit",
    "mcmc",
    "mcmc.list",
    "MCMCglmm",
    "mediate",
    "merMod",
    "merModList",
    "meta_bma",
    "meta_fixed",
    "meta_random",
    "meta_ordered",
    "metaplus",
    "mipo",
    "mira",
    "mixed",
    "mixor",
    "MixMod",
    "mjoint",
    "mle",
    "mle2",
    "mlergm",
    "mlm",
    "mlma",
    "mlogit",
    "multinom",
    "mvmeta",
    "mvr",
    "negbin",
    "negbinmfx",
    "negbinirr",
    "nlreg",
    "nlrq",
    "nls",
    "nparLD",
    "objectiveML",
    "ols",
    "osrt",
    "orcutt",
    "pairwise.htest",
    "pb1",
    "pb2",
    "plm",
    "plmm",
    "PMCMR",
    "poissonmfx",
    "poissonirr",
    "polr",
    "pseudoglm",
    "psm",
    "probitmfx",
    "rankFD",
    "Rchoice",
    "rdrobust",
    "ridgelm",
    "riskRegression",
    "rjags",
    "rlm",
    "rlme",
    "rlmerMod",
    "RM",
    "rma",
    "rmanovab",
    "rma.uni",
    "rms",
    "robmixglm",
    "robtab",
    "rq",
    "rqs",
    "rqss",
    "sarlm",
    "scam",
    "sem",
    "slm",
    "speedlm",
    "speedglm",
    "splmm",
    "spml",
    "stanmvreg",
    "stanreg",
    "summary.lm",
    "survfit",
    "survreg",
    "survPresmooth",
    "svyglm",
    "svy_vglm",
    "svyolr",
    "t1way",
    "t2way",
    "t3way",
    "test_mediation",
    "tobit",
    "trendPMCMR",
    "truncreg",
    "varest",
    "vgam",
    "vglm",
    "wbm",
    "wblm",
    "yuen",
    "zcpglm",
    "zeroinfl",
    "zerotrunc"
  )

  if (isTRUE(regression_only)) {
    out <- setdiff(out, c(
      "emmGrid", "emm_list", "htest", "pairwise.htest", "summary.lm"
    ))
  }

  out
}
