# insight <img src='man/figures/logo.png' align="right" height="139" />

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/insight)](https://cran.r-project.org/package=insight) [![Documentation](https://img.shields.io/badge/documentation-insight-orange.svg?colorB=E91E63)](https://easystats.github.io/insight/) [![Build Status](https://travis-ci.org/easystats/insight.svg?branch=master)](https://travis-ci.org/easystats/insight)
[![codecov](https://codecov.io/gh/easystats/insight/branch/master/graph/badge.svg)](https://codecov.io/gh/easystats/insight)
[![downloads](http://cranlogs.r-pkg.org/badges/insight)](http://cranlogs.r-pkg.org/) [![total](http://cranlogs.r-pkg.org/badges/grand-total/insight)](http://cranlogs.r-pkg.org/)

**Gain insight into your models!**

The goal of *insight* is to provide tools to help an **easy**, **intuitive** and **consistent** accesss to information contained in various models, like model formulas, model terms, information about random effects, data that was used to fit the model or data from response variables. Although there are generic functions to get information and data from models, many modelling-functions from different packages do not provide such methods to access these information. The *insight* package aims at closing this gap by providing functions that work for (almost) any model.

## Installation

Run the following to install the latest GitHub-version of *insight*:

```r
install.packages("devtools")
devtools::install_github("easystats/insight")
```

Or install the latest stable release from CRAN:

```r
install.packages("insight")
```

## Documentation and Support

Please visit [https://easystats.github.io/insight/](https://easystats.github.io/insight/) for documentation. In case you want to file an issue or contribute in another way to the package, please follow [this guide](CONTRIBUTING.md). For questions about the functionality, you may either contact me via email or also file an issue.

## Functions

The syntax of `insight` mainly revolves around two types of functions. One is to find the names of the *things* (`find_*`), and the second is to actually get the *things* (`get_`). The *things* can be the following:

- [find_algorithm()](https://easystats.github.io/insight/reference/find_algorithm.html)
- [find_formula()](https://easystats.github.io/insight/reference/find_formula.html)
- [find_variables()](https://easystats.github.io/insight/reference/find_variables.html)
- [find_terms()](https://easystats.github.io/insight/reference/find_terms.html)

- [get_data()](https://easystats.github.io/insight/reference/get_data.html)
- [get_priors()](https://easystats.github.io/insight/reference/get_priors.html)
- [get_variance()](https://easystats.github.io/insight/reference/get_variance.html)

- [find_parameters()](https://easystats.github.io/insight/reference/find_parameters.html) / [get_parameters()](https://easystats.github.io/insight/reference/get_parameters.html)
- [find_predictors()](https://easystats.github.io/insight/reference/find_predictors.html) / [get_predictors()](https://easystats.github.io/insight/reference/get_predictors.html)
- [find_random()](https://easystats.github.io/insight/reference/find_random.html) / [get_random()](https://easystats.github.io/insight/reference/get_random.html)
- [find_response()](https://easystats.github.io/insight/reference/find_response.html) /  [get_response()](https://easystats.github.io/insight/reference/get_response.html)

On top of that, the [`model_info()`](https://easystats.github.io/insight/reference/model_info.html) function runs many checks to help you classify and understand the nature of your model.


## List of Supported Packages and Models

**AER** (*ivreg, tobit*), **afex** (*mixed*), **base** (*aov, aovlist, lm, glm*), **BayesFactor** (*BFBayesFactor*), **betareg** (*betareg*), **biglm** (*biglm, bigglm*), **blme** (*blmer, bglmer*), **brms** (*brmsfit*), **censReg**, **crch**, **countreg** (*zerontrunc*), **coxme**, **estimatr** (*lm_robust, iv_robust*), **feisr** (*feis*), **gam** (*Gam*), **gamm4** , **gamlss**, **gbm**, **gee**, **geepack** (*geeglm*), **GLMMadaptive** (*MixMod*), **glmmTMB** (*glmmTMB*), **gmnl**, **lfe** (*felm*), **lme4** (*lmer, glmer, nlmer, glmer.nb*), **MASS** (*glmmPQL, polr*), **mgcv** (*gam, gamm*), **multgee** (*LORgee*), **nnet** (*multinom*), **nlme** (*lme, gls*), **ordinal** (*clm, clm2, clmm*), **plm**, **pscl** (*zeroinf, hurdle*), **quantreg** (*rq, crq, rqss*), **rms** (*lsr, ols, psm*), **robust** (*glmRob, lmRob*), **robustbase** (*glmrob, lmrob*), **robustlmm** (*rlmer*), **rstanarm** (*stanreg, stanmvreg*), **speedlm** (*speedlm, speedglm*), **survey**, **survival** (*coxph, survreg*), **truncreg** (*truncreg*), **VGAM** (*vgam, vglm*)

- **Didn't find a model?** [File an issue](https://github.com/easystats/insight/issues) and request additional model-support in _insight_!


## Credits

If this package helped you, please consider citing as follows:

- Lüdecke D, Makowski D (2019). *insight: Easy Access to Model Information for Various Model Objects*. R package. https://easystats.github.io/insight/.

