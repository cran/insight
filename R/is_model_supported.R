#' @title Checks if an object is a regression model object supported in
#'   \pkg{insight} package.
#' @name is_model_supported
#'
#' @description Small helper that checks if a model is a \emph{supported}
#'  (regression) model object. \code{supported_models()} prints a list
#'  of currently supported model classes.
#'
#' @inheritParams is_model
#'
#' @return A logical, \code{TRUE} if \code{x} is a (supported) model object.
#'
#' @details This function returns \code{TRUE} if \code{x} is a model object
#'   that works with the package's functions. A list of supported models can
#'   also be found here: \url{https://github.com/easystats/insight}.
#'
#' @examples
#' data(mtcars)
#' m <- lm(mpg ~ wt + cyl + vs, data = mtcars)
#'
#' is_model_supported(m)
#' is_model_supported(mtcars)
#' @export
is_model_supported <- function(x) {
  inherits(x, .supported_models_list())
}


#' @rdname is_model_supported
#' @export
supported_models <- function() {
  sort(.supported_models_list())
}




.supported_models_list <- function() {
  c(
    "aareg",
    "afex_aov",
    "aov",
    "aovlist",
    "Anova.mlm",
    "Arima",
    "averaging",
    "bamlss",
    "bamlss.frame",
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
    "bife",
    "biglm",
    "bigglm",
    "blavaan",
    "blrm",
    "bracl",
    "brglm",
    "brmsfit",
    "brmultinom",
    "btergm",
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
    "DirichletRegModel",
    "eglm",
    "elm",
    "ergm",
    "feis",
    "felm",
    "feglm",
    "fitdistr",
    "fixest",
    "flexsurvreg",
    "gam",
    "Gam",
    "gamlss",
    "gamm",
    "gamm4",
    "garch",
    "gbm",
    "gee",
    "geeglm",
    "glht",
    "glimML",
    "glmm",
    "glm",
    "Glm",
    "glmmadmb",
    "glmmPQL",
    "glmmTMB",
    "glmrob",
    "glmRob",
    "glmx",
    "gls",
    "gmnl",
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
    "lmerMod",
    "lmerModLmerTest",
    "lmodel2",
    "logitmfx",
    "logitor",
    "logistf",
    "LORgee",
    "lqm",
    "lqmm",
    "lrm",
    "manova",
    "MANOVA",
    "margins",
    "maxLik",
    "mcmc",
    "MCMCglmm",
    "mediate",
    "metaplus",
    "merMod",
    "merModList",
    "mipo",
    "mira",
    "mixed",
    "mixor",
    "MixMod",
    "mle",
    "mle2",
    "mlm",
    "mclogit",
    "mcmc.list",
    "meta_bma",
    "meta_fixed",
    "meta_random",
    "mlogit",
    "mmlogit",
    "multinom",
    "negbinmfx",
    "negbinirr",
    "ols",
    "poissonmfx",
    "poissonirr",
    "plm",
    "polr",
    "psm",
    "probitmfx",
    "Rchoice",
    "ridgelm",
    "riskRegression",
    "rlm",
    "rlmerMod",
    "RM",
    "rma",
    "rma.uni",
    "robmixglm",
    "rq",
    "rqs",
    "rqss",
    "scam",
    "sem",
    "speedlm",
    "speedglm",
    "stanmvreg",
    "stanreg",
    "summary.lm",
    "survfit",
    "survreg",
    "svyglm",
    "svyolr",
    "tobit",
    "truncreg",
    "vgam",
    "vglm",
    "wbm",
    "wblm",
    "wbgee",
    "zcpglm",
    "zeroinfl",
    "zerotrunc"
  )
}
