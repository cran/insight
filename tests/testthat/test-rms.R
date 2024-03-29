skip_if_not_installed("rms")

data(mtcars)
m1 <- rms::lrm(am ~ mpg + gear, data = mtcars)

test_that("model_info", {
  expect_true(model_info(m1)$is_bernoulli)
  expect_true(model_info(m1)$is_binomial)
  expect_true(model_info(m1)$is_logit)
  expect_false(model_info(m1)$is_linear)
  expect_false(model_info(m1)$is_ordinal)
})

test_that("find_predictors", {
  expect_identical(find_predictors(m1), list(conditional = c("mpg", "gear")))
  expect_identical(find_predictors(m1, flatten = TRUE), c("mpg", "gear"))
  expect_null(find_predictors(m1, effects = "random"))
})

test_that("find_random", {
  expect_null(find_random(m1))
})

test_that("get_random", {
  expect_warning(get_random(m1))
})

test_that("find_response", {
  expect_identical(find_response(m1), "am")
})

test_that("get_response", {
  expect_identical(get_response(m1), mtcars$am)
})

test_that("get_predictors", {
  expect_named(get_predictors(m1), c("mpg", "gear"))
})

test_that("link_inverse", {
  expect_equal(link_inverse(m1)(0.2), plogis(0.2), tolerance = 1e-5)
})

test_that("get_data", {
  expect_identical(nrow(get_data(m1)), 32L)
  expect_named(get_data(m1), c("am", "mpg", "gear"))
})

test_that("find_formula", {
  expect_length(find_formula(m1), 1)
  expect_equal(
    find_formula(m1),
    list(conditional = as.formula("am ~ mpg + gear")),
    ignore_attr = TRUE
  )
})

test_that("find_terms", {
  expect_identical(find_terms(m1), list(
    response = "am",
    conditional = c("mpg", "gear")
  ))
  expect_identical(find_terms(m1, flatten = TRUE), c("am", "mpg", "gear"))
})

test_that("n_obs", {
  expect_identical(n_obs(m1), 32)
})

test_that("linkfun", {
  expect_false(is.null(link_function(m1)))
})

test_that("linkinverse", {
  expect_false(is.null(link_inverse(m1)))
})

test_that("find_parameters", {
  expect_identical(
    find_parameters(m1),
    list(conditional = c("Intercept", "mpg", "gear"))
  )
  expect_identical(nrow(get_parameters(m1)), 3L)
  expect_identical(
    get_parameters(m1)$Parameter,
    c("Intercept", "mpg", "gear")
  )
})

test_that("is_multivariate", {
  expect_false(is_multivariate(m1))
})

test_that("find_algorithm", {
  expect_identical(find_algorithm(m1), list(algorithm = "ML"))
})

test_that("find_statistic", {
  expect_identical(find_statistic(m1), "z-statistic")
})

m2 <- rms::orm(mpg ~ cyl + disp + hp + drat, data = mtcars)
aov_model <- anova(m2)

test_that("find_statistic anova", {
  expect_identical(find_statistic(aov_model), "chi-squared statistic")
})

test_that("find_parameters anova", {
  expect_identical(find_parameters(aov_model), list(conditional = c("cyl", "disp", "hp", "drat", "TOTAL")))
})

test_that("get_statistic anova", {
  expect_identical(
    get_statistic(aov_model)$Statistic,
    aov_model[, 1],
    ignore_attr = TRUE,
    tolerance = 1e-3
  )
})

# correctly identify ordinal models

test_that("model_info for ordinal outcome", {
  data(mtcars)
  mtcars$cyl_ord <- ordered(mtcars$cyl)
  # fit olr
  fit <- rms::lrm(cyl_ord ~ hp, data = mtcars, tol = 1e-22)
  expect_false(model_info(fit)$is_bernoulli)
  expect_true(model_info(fit)$is_ordinal)
})
