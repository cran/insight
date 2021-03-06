.runThisTest <- Sys.getenv("RunAllinsightTests") == "yes"

if (.runThisTest) {
  if (suppressWarnings(require("testthat") &&
    require("insight") &&
    require("BayesFactor") &&
    require("rstanarm"))) {
    m1 <- insight::download_model("stanreg_merMod_5")
    m2 <- insight::download_model("stanreg_glm_6")
    m3 <- insight::download_model("stanreg_glm_1")

    data("puzzles")
    m4 <-
      stan_glm(
        RT ~ color * shape,
        data = puzzles,
        prior = rstanarm::cauchy(0, c(3, 1, 2)),
        iter = 500,
        chains = 2,
        refresh = 0
      )
    m5 <-
      stan_glm(
        RT ~ color * shape,
        data = puzzles,
        prior = rstanarm::cauchy(0, c(1, 2, 3)),
        iter = 500,
        chains = 2,
        refresh = 0
      )
    m6 <- insight::download_model("stanreg_gamm4_1")

    test_that("n_parameters", {
      expect_equal(n_parameters(m1), 21)
      expect_equal(n_parameters(m1, effects = "fixed"), 5)
    })

    test_that("get_priors", {
      expect_equal(
        colnames(get_priors(m1)),
        c("Parameter", "Distribution", "Location", "Scale")
      )
      expect_equal(
        colnames(get_priors(m2)),
        c(
          "Parameter",
          "Distribution",
          "Location",
          "Scale",
          "Adjusted_Scale"
        )
      )
      expect_equal(get_priors(m1)$Scale, c(2.5, 2.5, 2.5, 2.5, 2.5), tolerance = 1e-3)
      expect_equal(get_priors(m2)$Adjusted_Scale, c(1.08967, 2.30381, 2.30381, 0.61727, 0.53603, 0.41197), tolerance = 1e-3)
      expect_equal(get_priors(m3)$Adjusted_Scale, c(NA, 2.555042), tolerance = 1e-3)
      expect_equal(get_priors(m4)$Adjusted_Scale, c(6.399801, NA, NA, NA), tolerance = 1e-3)
      expect_equal(get_priors(m5)$Adjusted_Scale, c(6.399801, NA, NA, NA), tolerance = 1e-3)
      expect_equal(
        get_priors(m6),
        data.frame(
          Parameter = "(Intercept)",
          Distribution = "normal",
          Location = 3.057333,
          Scale = 2.5,
          Adjusted_Scale = 1.089666,
          stringsAsFactors = FALSE,
          row.names = NULL
        ),
        tolerance = 1e-3
      )
    })


    test_that("clean_names", {
      expect_identical(
        clean_names(m1),
        c("incidence", "size", "period", "herd")
      )
    })


    test_that("find_predictors", {
      expect_identical(find_predictors(m1), list(conditional = c("size", "period")))
      expect_identical(find_predictors(m1, flatten = TRUE), c("size", "period"))
      expect_identical(
        find_predictors(m1, effects = "all", component = "all"),
        list(
          conditional = c("size", "period"),
          random = "herd"
        )
      )
      expect_identical(
        find_predictors(
          m1,
          effects = "all",
          component = "all",
          flatten = TRUE
        ),
        c("size", "period", "herd")
      )
    })

    test_that("find_response", {
      expect_equal(
        find_response(m1, combine = TRUE),
        "cbind(incidence, size - incidence)"
      )
      expect_equal(
        find_response(m1, combine = FALSE),
        c("incidence", "size")
      )
    })

    test_that("get_response", {
      expect_equal(nrow(get_response(m1)), 56)
      expect_equal(colnames(get_response(m1)), c("incidence", "size"))
    })

    test_that("find_random", {
      expect_equal(find_random(m1), list(random = "herd"))
    })

    test_that("get_random", {
      expect_equal(get_random(m1), lme4::cbpp[, "herd", drop = FALSE])
    })

    test_that("find_terms", {
      expect_identical(
        find_terms(m1),
        list(
          response = "cbind(incidence, size - incidence)",
          conditional = c("size", "period"),
          random = "herd"
        )
      )
    })

    test_that("find_variables", {
      expect_identical(
        find_variables(m1),
        list(
          response = c("incidence", "size"),
          conditional = c("size", "period"),
          random = "herd"
        )
      )
      expect_identical(
        find_variables(m1, effects = "fixed"),
        list(
          response = c("incidence", "size"),
          conditional = c("size", "period")
        )
      )
      expect_null(find_variables(m1, component = "zi"))
    })

    test_that("n_obs", {
      expect_equal(n_obs(m1), 842)
    })

    test_that("find_paramaters", {
      expect_equal(
        find_parameters(m1),
        list(
          conditional = c("(Intercept)", "size", "period2", "period3", "period4"),
          random = c(sprintf("b[(Intercept) herd:%i]", 1:15), "Sigma[herd:(Intercept),(Intercept)]")
        )
      )
      expect_equal(
        find_parameters(m1, flatten = TRUE),
        c(
          "(Intercept)",
          "size",
          "period2",
          "period3",
          "period4",
          sprintf("b[(Intercept) herd:%i]", 1:15),
          "Sigma[herd:(Intercept),(Intercept)]"
        )
      )
    })

    test_that("find_paramaters", {
      expect_equal(
        colnames(get_parameters(m1)),
        c("(Intercept)", "size", "period2", "period3", "period4")
      )
      expect_equal(
        colnames(get_parameters(m1, effects = "all")),
        c(
          "(Intercept)",
          "size",
          "period2",
          "period3",
          "period4",
          sprintf("b[(Intercept) herd:%i]", 1:15),
          "Sigma[herd:(Intercept),(Intercept)]"
        )
      )
    })

    test_that("linkfun", {
      expect_false(is.null(link_function(m1)))
    })

    test_that("link_inverse", {
      expect_equal(link_inverse(m1)(.2), plogis(.2), tolerance = 1e-4)
    })

    test_that("get_data", {
      expect_equal(nrow(get_data(m1)), 56)
      expect_equal(
        colnames(get_data(m1)),
        c("incidence", "size", "period", "herd")
      )
    })

    test_that("find_formula", {
      expect_length(find_formula(m1), 2)
      expect_equal(
        find_formula(m1),
        list(
          conditional = as.formula("cbind(incidence, size - incidence) ~ size + period"),
          random = as.formula("~1 | herd")
        ),
        ignore_attr = TRUE
      )
    })

    test_that("get_variance", {
      expect_equal(
        get_variance(m1),
        list(
          var.fixed = 0.36274,
          var.random = 0.03983,
          var.residual = 3.28987,
          var.distribution = 3.28987,
          var.dispersion = 0,
          var.intercept = c(herd = 0.59889)
        ),
        tolerance = 1e-3
      )

      expect_equal(get_variance_fixed(m1),
        c(var.fixed = 0.3627389),
        tolerance = 1e-4
      )
      expect_equal(get_variance_random(m1),
        c(var.random = 0.03983106),
        tolerance = 1e-4
      )
      expect_equal(get_variance_residual(m1),
        c(var.residual = 3.289868),
        tolerance = 1e-4
      )
      expect_equal(get_variance_distribution(m1),
        c(var.distribution = 3.289868),
        tolerance = 1e-4
      )
      expect_equal(get_variance_dispersion(m1),
        c(var.dispersion = 0),
        tolerance = 1e-4
      )
    })

    test_that("find_algorithm", {
      expect_equal(
        find_algorithm(m1),
        list(
          algorithm = "sampling",
          chains = 2,
          iterations = 500,
          warmup = 250
        )
      )
    })

    test_that("clean_parameters", {
      expect_equal(
        clean_parameters(m2),
        structure(
          list(
            Parameter = c(
              "(Intercept)",
              "Speciesversicolor",
              "Speciesvirginica",
              "Petal.Length",
              "Speciesversicolor:Petal.Length",
              "Speciesvirginica:Petal.Length",
              "sigma"
            ),
            Effects = c(
              "fixed", "fixed", "fixed",
              "fixed", "fixed", "fixed", "fixed"
            ),
            Component = c(
              "conditional",
              "conditional",
              "conditional",
              "conditional",
              "conditional",
              "conditional",
              "sigma"
            ),
            Cleaned_Parameter = c(
              "(Intercept)",
              "Speciesversicolor",
              "Speciesvirginica",
              "Petal.Length",
              "Speciesversicolor:Petal.Length",
              "Speciesvirginica:Petal.Length",
              "sigma"
            )
          ),
          class = c("clean_parameters", "data.frame"),
          row.names = c(NA, -7L)
        ),
        ignore_attr = TRUE
      )
    })

    test_that("find_statistic", {
      expect_null(find_statistic(m1))
      expect_null(find_statistic(m2))
      expect_null(find_statistic(m3))
      expect_null(find_statistic(m4))
      expect_null(find_statistic(m5))
      expect_null(find_statistic(m6))
    })

    model <- stan_glm(
      disp ~ carb,
      data = mtcars,
      priors = NULL,
      prior_intercept = NULL,
      refresh = 0
    )

    test_that("flat_priors", {
      p <- get_priors(model)
      expect_equal(p$Distribution, c("uniform", "normal"))
      expect_equal(p$Location, c(NA, 0), tolerance = 1e-3)
    })
  }
}
