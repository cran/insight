skip_if_not_installed("curl")
skip_if_offline()
skip_if_not_installed("VGAM")

data("hunua", package = "VGAM")

m1 <- download_model("vgam_1")
m2 <- download_model("vgam_2")

skip_if(is.null(m1))
skip_if(is.null(m2))

test_that("model_info", {
  expect_true(model_info(m1)$is_binomial)
  expect_true(model_info(m2)$is_binomial)
  expect_false(model_info(m1)$is_bayesian)
  expect_false(model_info(m2)$is_bayesian)
})

test_that("find_predictors", {
  expect_identical(find_predictors(m1), list(conditional = c("vitluc", "altitude")))
  expect_identical(
    find_predictors(m1, flatten = TRUE),
    c("vitluc", "altitude")
  )
  expect_null(find_predictors(m1, effects = "random"))
  expect_identical(find_predictors(m2), list(conditional = c("vitluc", "altitude")))
  expect_identical(
    find_predictors(m2, flatten = TRUE),
    c("vitluc", "altitude")
  )
  expect_null(find_predictors(m2, effects = "random"))
})

test_that("find_random", {
  expect_null(find_random(m1))
  expect_null(find_random(m2))
})

test_that("get_random", {
  expect_warning(get_random(m1))
  expect_warning(get_random(m2))
})

test_that("find_response", {
  expect_identical(find_response(m1), "agaaus")
  expect_identical(find_response(m2), "cbind(agaaus, kniexc)")
  expect_identical(find_response(m2, combine = FALSE), c("agaaus", "kniexc"))
})

test_that("get_response", {
  expect_identical(get_response(m1), hunua$agaaus)
  expect_equal(
    get_response(m2),
    data.frame(agaaus = hunua$agaaus, kniexc = hunua$kniexc),
    ignore_attr = TRUE
  )
})

test_that("get_predictors", {
  expect_identical(colnames(get_predictors(m1)), c("vitluc", "altitude"))
  expect_identical(colnames(get_predictors(m2)), c("vitluc", "altitude"))
})

test_that("link_inverse", {
  expect_equal(link_inverse(m1)(0.2), plogis(0.2), tolerance = 1e-5)
  expect_equal(link_inverse(m2)(0.2), plogis(0.2), tolerance = 1e-5)
})

test_that("get_data", {
  expect_identical(nrow(get_data(m1)), 392L)
  expect_identical(nrow(get_data(m2)), 392L)
  expect_identical(colnames(get_data(m1)), c("agaaus", "vitluc", "altitude"))
  expect_identical(
    colnames(get_data(m2)),
    c("agaaus", "kniexc", "vitluc", "altitude")
  )
})

test_that("find_formula", {
  expect_length(find_formula(m1), 1)
  expect_equal(
    find_formula(m1),
    list(conditional = as.formula("agaaus ~ vitluc + s(altitude, df = 2)")),
    ignore_attr = TRUE
  )
  expect_length(find_formula(m2), 1)
  expect_equal(
    find_formula(m2),
    list(
      conditional = as.formula("cbind(agaaus, kniexc) ~ vitluc + s(altitude, df = c(2, 3))")
    ),
    ignore_attr = TRUE
  )
})

test_that("find_terms", {
  expect_identical(
    find_terms(m1),
    list(
      response = "agaaus",
      conditional = c("vitluc", "s(altitude, df = 2)")
    )
  )
  expect_identical(
    find_terms(m1, flatten = TRUE),
    c("agaaus", "vitluc", "s(altitude, df = 2)")
  )
  expect_identical(
    find_terms(m2),
    list(
      response = "cbind(agaaus, kniexc)",
      conditional = c("vitluc", "s(altitude, df = c(2, 3))")
    )
  )
  expect_identical(
    find_terms(m2, flatten = TRUE),
    c(
      "cbind(agaaus, kniexc)",
      "vitluc",
      "s(altitude, df = c(2, 3))"
    )
  )
})

test_that("find_variables", {
  expect_identical(
    find_variables(m1),
    list(
      response = "agaaus",
      conditional = c("vitluc", "altitude")
    )
  )
  expect_identical(
    find_variables(m1, flatten = TRUE),
    c("agaaus", "vitluc", "altitude")
  )
  expect_identical(find_variables(m2), list(
    response = c("agaaus", "kniexc"),
    conditional = c("vitluc", "altitude")
  ))
  expect_identical(
    find_variables(m2, flatten = TRUE),
    c("agaaus", "kniexc", "vitluc", "altitude")
  )
})

test_that("n_obs", {
  expect_identical(n_obs(m1), 392L)
  expect_identical(n_obs(m2), 392L)
})

test_that("linkfun", {
  expect_false(is.null(link_function(m1)))
  expect_false(is.null(link_function(m2)))
})

test_that("find_parameters", {
  expect_identical(
    find_parameters(m1),
    list(
      conditional = c("(Intercept)", "vitluc"),
      smooth_terms = "s(altitude, df = 2)"
    )
  )
  expect_identical(nrow(get_parameters(m1)), 3L)
  expect_identical(
    get_parameters(m1)$Parameter,
    c("(Intercept)", "vitluc", "s(altitude, df = 2)")
  )

  expect_identical(
    find_parameters(m2),
    list(
      conditional = c(
        "(Intercept):1",
        "(Intercept):2",
        "vitluc:1",
        "vitluc:2"
      ),
      smooth_terms = c("s(altitude, df = c(2, 3)):1", "s(altitude, df = c(2, 3)):2")
    )
  )
  expect_identical(nrow(get_parameters(m2)), 6L)
  expect_identical(
    get_parameters(m2)$Parameter,
    c(
      "(Intercept):1",
      "(Intercept):2",
      "vitluc:1",
      "vitluc:2",
      "s(altitude, df = c(2, 3)):1",
      "s(altitude, df = c(2, 3)):2"
    )
  )
})

test_that("is_multivariate", {
  expect_false(is_multivariate(m1))
  expect_true(is_multivariate(m2))
})

test_that("find_statistic", {
  expect_identical(find_statistic(m1), "chi-squared statistic")
  expect_identical(find_statistic(m2), "chi-squared statistic")
})
