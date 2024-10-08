m1 <- lm(Sepal.Length ~ Petal.Width + Species, data = iris)
m2 <- lm(log(mpg) ~ log(hp) + cyl + I(cyl^2) + poly(wt, degree = 2, raw = TRUE),
  data = mtcars
)

test_that("model_info", {
  expect_true(model_info(m1)$is_linear)
  expect_false(model_info(m1)$is_bayesian)
})

test_that("get_residuals", {
  expect_equal(
    head(get_residuals(m2)),
    head(stats::residuals(m2)),
    tolerance = 1e-3,
    ignore_attr = TRUE
  )
})

test_that("get_sigma", {
  expect_equal(get_sigma(m1), 0.4810113, tolerance = 1e-3, ignore_attr = TRUE)
})

test_that("find_predictors", {
  expect_identical(find_predictors(m1), list(conditional = c("Petal.Width", "Species")))
  expect_identical(
    find_predictors(m1, flatten = TRUE),
    c("Petal.Width", "Species")
  )
  expect_null(find_predictors(m1, effects = "random"))

  expect_identical(find_predictors(m2), list(conditional = c("hp", "cyl", "wt")))
  expect_identical(find_predictors(m2, flatten = TRUE), c("hp", "cyl", "wt"))
  expect_null(find_predictors(m2, effects = "random"))
})

test_that("find_response", {
  expect_identical(find_response(m1), "Sepal.Length")
  expect_identical(find_response(m2), "mpg")
})

test_that("link_inverse", {
  expect_identical(link_inverse(m1)(0.2), 0.2)
  expect_identical(link_inverse(m2)(0.2), 0.2)
})

test_that("loglik", {
  expect_equal(get_loglikelihood(m1), logLik(m1), ignore_attr = TRUE)
  expect_equal(get_loglikelihood(m2), logLik(m2), ignore_attr = TRUE)
})

test_that("get_df", {
  expect_equal(get_df(m1), df.residual(m1), ignore_attr = TRUE)
  expect_equal(get_df(m2), df.residual(m2), ignore_attr = TRUE)
  expect_equal(get_df(m1, type = "model"), attr(logLik(m1), "df"), ignore_attr = TRUE)
  expect_equal(get_df(m2, type = "model"), attr(logLik(m2), "df"), ignore_attr = TRUE)
})

test_that("get_df", {
  expect_equal(
    get_df(m1, type = "residual"),
    df.residual(m1),
    ignore_attr = TRUE
  )
  expect_equal(
    get_df(m1, type = "normal"),
    Inf,
    ignore_attr = TRUE
  )
  expect_equal(
    get_df(m1, type = "wald"),
    df.residual(m1),
    ignore_attr = TRUE
  )
})

test_that("get_data", {
  expect_identical(nrow(get_data(m1)), 150L)
  expect_named(get_data(m1), c("Sepal.Length", "Petal.Width", "Species"))
  expect_identical(nrow(get_data(m2)), 32L)
  expect_named(get_data(m2), c("mpg", "hp", "cyl", "wt"))
})

test_that("get_intercept", {
  expect_equal(get_intercept(m1), as.vector(stats::coef(m1)[1]), ignore_attr = TRUE)
  expect_equal(get_intercept(m2), as.vector(stats::coef(m2)[1]), ignore_attr = TRUE)
})

test_that("find_formula", {
  expect_length(find_formula(m1), 1)
  expect_equal(
    find_formula(m1),
    list(conditional = as.formula("Sepal.Length ~ Petal.Width + Species")),
    ignore_attr = TRUE
  )

  expect_length(find_formula(m2), 1)
  expect_equal(
    find_formula(m2),
    list(
      conditional = as.formula(
        "log(mpg) ~ log(hp) + cyl + I(cyl^2) + poly(wt, degree = 2, raw = TRUE)"
      )
    ),
    ignore_attr = TRUE
  )
})

test_that("find_terms", {
  expect_identical(
    find_terms(m1),
    list(
      response = "Sepal.Length",
      conditional = c("Petal.Width", "Species")
    )
  )
  expect_identical(
    find_terms(m2),
    list(
      response = "log(mpg)",
      conditional = c(
        "log(hp)",
        "cyl",
        "I(cyl^2)",
        "poly(wt, degree = 2, raw = TRUE)"
      )
    )
  )
  expect_identical(
    find_terms(m1, flatten = TRUE),
    c("Sepal.Length", "Petal.Width", "Species")
  )
  expect_identical(
    find_terms(m2, flatten = TRUE),
    c(
      "log(mpg)",
      "log(hp)",
      "cyl",
      "I(cyl^2)",
      "poly(wt, degree = 2, raw = TRUE)"
    )
  )
})

test_that("find_variables", {
  expect_identical(
    find_variables(m1),
    list(
      response = "Sepal.Length",
      conditional = c("Petal.Width", "Species")
    )
  )
  expect_identical(find_variables(m2), list(
    response = "mpg",
    conditional = c("hp", "cyl", "wt")
  ))
  expect_identical(
    find_variables(m1, flatten = TRUE),
    c("Sepal.Length", "Petal.Width", "Species")
  )
  expect_identical(
    find_variables(m2, flatten = TRUE),
    c("mpg", "hp", "cyl", "wt")
  )
})

test_that("find_parameters", {
  expect_identical(
    find_parameters(m1),
    list(
      conditional = c(
        "(Intercept)",
        "Petal.Width",
        "Speciesversicolor",
        "Speciesvirginica"
      )
    )
  )
  expect_identical(nrow(get_parameters(m1)), 4L)
  expect_identical(
    get_parameters(m1)$Parameter,
    c(
      "(Intercept)",
      "Petal.Width",
      "Speciesversicolor",
      "Speciesvirginica"
    )
  )
})


test_that("find_parameters summary.lm", {
  s <- summary(m1)
  expect_identical(
    find_parameters(s),
    list(
      conditional = c(
        "(Intercept)",
        "Petal.Width",
        "Speciesversicolor",
        "Speciesvirginica"
      )
    )
  )
})

test_that("linkfun", {
  expect_false(is.null(link_function(m1)))
  expect_false(is.null(link_function(m2)))
})

test_that("find_algorithm", {
  expect_identical(find_algorithm(m1), list(algorithm = "OLS"))
})

test_that("get_variance", {
  expect_warning(expect_null(get_variance(m1)))
  expect_warning(expect_null(get_variance_dispersion(m1)))
  expect_warning(expect_null(get_variance_distribution(m1)))
  expect_warning(expect_null(get_variance_fixed(m1)))
  expect_warning(expect_null(get_variance_intercept(m1)))
  expect_warning(expect_null(get_variance_random(m1)))
  expect_warning(expect_null(get_variance_residual(m1)))
})

test_that("is_model", {
  expect_true(is_model(m1))
})

test_that("all_models_equal", {
  expect_true(all_models_equal(m1, m2))
})

test_that("get_varcov", {
  expect_equal(diag(get_varcov(m1)), diag(vcov(m1)), tolerance = 1e-5)
})

test_that("get_statistic", {
  expect_equal(get_statistic(m1)$Statistic, c(57.5427, 4.7298, -0.2615, -0.1398), tolerance = 1e-3)
})

test_that("find_statistic", {
  expect_identical(find_statistic(m1), "t-statistic")
})


data("DNase")
DNase1 <- subset(DNase, Run == 1)
m3 <-
  stats::nls(
    density ~ stats::SSlogis(log(conc), Asym, xmid, scal),
    DNase1,
    start = list(
      Asym = 1,
      xmid = 1,
      scal = 1
    )
  )

## Dobson (1990) Page 93: Randomized Controlled Trial :
counts <- c(18, 17, 15, 20, 10, 20, 25, 13, 12)
outcome <- gl(3, 1, 9)
treatment <- gl(3, 3)
m4 <- glm(counts ~ outcome + treatment, family = poisson())

test_that("is_model", {
  expect_true(is_model(m3))
})

test_that("is_model", {
  expect_false(is_model_supported(m3))
})

test_that("all_models_equal", {
  expect_false(all_models_equal(m1, m2, m3))
  expect_false(all_models_equal(m1, m2, m4))
})

test_that("find_statistic", {
  expect_identical(find_statistic(m1), "t-statistic")
  expect_identical(find_statistic(m2), "t-statistic")
  expect_identical(find_statistic(m3), "t-statistic")
  expect_identical(find_statistic(m4), "z-statistic")
})

test_that("find_statistic", {
  m <- lm(cbind(mpg, hp) ~ cyl + drat, data = mtcars)
  expect_message(
    get_predicted(m),
    "not yet supported for models of class `mlm`"
  )
  expect_s3_class(suppressMessages(get_predicted(m)), "get_predicted")
})
